From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: fix incorrect error return path on tmp
 allocation failure
Date: Fri, 28 Oct 2016 20:16:33 +0200
Message-ID: <1477678593.4220.2.camel@sipsolutions.net>
References: <20161028180824.7110-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161028180824.7110-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-28 at 19:08 +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The current exit path when tmp fails to be allocated is via the
> fail label which frees tfm2 which has not yet been allocated,
> which is problematic since tfm2 is not initialized and is a garbage
> pointer. Fix this by exiting directly to the return at the end
> of the function and hence avoiding the freeing of tfm2.

Yeah, thanks. Arnd beat you to the fix by about 8 hours, so I've
already applied his patch and sent an updated pull request :)

johannes
