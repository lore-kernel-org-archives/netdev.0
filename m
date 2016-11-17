From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] cw1200: fix bogus maybe-uninitialized warning
Date: Thu, 17 Nov 2016 06:48:19 +0000 (UTC)
Message-ID: <20161117064819.96A68615B1@smtp.codeaurora.org>
References: <20161025202121.1070879-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Solomon Peachy <pizza@shaftnet.org>,
        David Laight <David.Laight@ACULAB.COM>,
        Arnd Bergmann <arnd@arndb.de>,
        Johannes Berg <johannes.berg@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161025202121.1070879-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:
> On x86, the cw1200 driver produces a rather silly warning about the
> possible use of the 'ret' variable without an initialization
> presumably after being confused by the architecture specific definition
> of WARN_ON:
> 
> drivers/net/wireless/st/cw1200/wsm.c: In function ‘wsm_handle_rx’:
> drivers/net/wireless/st/cw1200/wsm.c:1457:9: error: ‘ret’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> We have already checked that 'count' is larger than 0 here, so
> we know that 'ret' is initialized. Changing the 'for' loop
> into do/while also makes this clear to the compiler.
> 
> Suggested-by: David Laight <David.Laight@ACULAB.COM>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Patch applied to wireless-drivers-next.git, thanks.

7fc1503c906f cw1200: fix bogus maybe-uninitialized warning

-- 
https://patchwork.kernel.org/patch/9395413/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
