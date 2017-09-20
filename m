From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/2] b43: fix unitialized reads of ret by initializing the array
 to zero
Date: Wed, 20 Sep 2017 12:41:24 +0000 (UTC)
Message-ID: <20170920124124.7B32460725@smtp.codeaurora.org>
References: <20170905181550.23839-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170905181550.23839-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:

> From: Colin Ian King <colin.king@canonical.com>
> 
> The u8 char array ret is not being initialized and elements outside
> the range start to end contain just garbage values from the stack.
> This results in a later scan of the array to read potentially
> uninitialized values.  Fix this by initializing the array to zero.
> This seems to have been an issue since the very first commit.
> 
> Detected by CoverityScan CID#139652 ("Uninitialized scalar variable")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Reviewed-by: Michael Buesch <m@bues.ch>

2 patches applied to wireless-drivers-next.git, thanks.

e31fbe1034d9 b43: fix unitialized reads of ret by initializing the array to zero
e3ae1c772046 b43legacy: fix unitialized reads of ret by initializing the array to zero

-- 
https://patchwork.kernel.org/patch/9939435/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
