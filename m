From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [2/2] zd1211rw: fix NULL-deref at probe
Date: Wed, 22 Mar 2017 09:04:15 +0000 (UTC)
Message-ID: <20170322090415.BE414609FF@smtp.codeaurora.org>
References: <20170313124421.28587-2-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
        Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170313124421.28587-2-johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Make sure to check the number of endpoints to avoid dereferencing a
> NULL-pointer or accessing memory beyond the endpoint array should a
> malicious device lack the expected endpoints.
> 
> Fixes: a1030e92c150 ("[PATCH] zd1211rw: Convert installer CDROM device into WLAN device")
> Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
> Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Patch applied to wireless-drivers-next.git, thanks.

ca260ece6a57 zd1211rw: fix NULL-deref at probe

-- 
https://patchwork.kernel.org/patch/9620721/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
