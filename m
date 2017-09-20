From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [1/2] b43: fix unitialized reads of ret by initializing the array
 to zero
Date: Wed, 20 Sep 2017 12:41:24 +0000 (UTC)
Message-ID: <20170920124124.5440D60724@smtp.codeaurora.org>
References: <20170905181550.23839-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170905181550.23839-1-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:

> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> 
> The u8 char array ret is not being initialized and elements outside
> the range start to end contain just garbage values from the stack.
> This results in a later scan of the array to read potentially
> uninitialized values.  Fix this by initializing the array to zero.
> This seems to have been an issue since the very first commit.
> 
> Detected by CoverityScan CID#139652 ("Uninitialized scalar variable")
> 
> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Reviewed-by: Michael Buesch <m@bues.ch>

2 patches applied to wireless-drivers-next.git, thanks.

e31fbe1034d9 b43: fix unitialized reads of ret by initializing the array to zero
e3ae1c772046 b43legacy: fix unitialized reads of ret by initializing the array to zero

-- 
https://patchwork.kernel.org/patch/9939435/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
