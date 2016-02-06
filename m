From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: brcmfmac: sdio: Increase the default timeouts a bit
Date: Sat,  6 Feb 2016 11:59:10 +0000 (UTC)
Message-ID: <20160206115910.BEE1F60226@smtp.codeaurora.org>
References: <1453718849-3508-1-git-send-email-sjoerd.simons@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "Franky \(Zhenhui\) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
 brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Doug Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
 Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
 Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sjoerd Simons <sjoerd.simons-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1453718849-3508-1-git-send-email-sjoerd.simons-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


> On a Radxa Rock2 board with a Ampak AP6335 (Broadcom 4339 core) it seems
> the card responds very quickly most of the time, unfortunately during
> initialisation it sometimes seems to take just a bit over 2 seconds to
> respond.
> 
> This results intialization failing with message like:
>   brcmf_c_preinit_dcmds: Retreiving cur_etheraddr failed, -52
>   brcmf_bus_start: failed: -52
>   brcmf_sdio_firmware_callback: dongle is not responding
> 
> Increasing the timeout to allow for a bit more headroom allows the
> card to initialize reliably.
> 
> A quick search online after diagnosing/fixing this showed that Google
> has a similar patch in their ChromeOS tree, so this doesn't seem
> specific to the board I'm using.
> 
> Signed-off-by: Sjoerd Simons <sjoerd.simons-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
> Reviewed-by: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Acked-by: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Reviewed-by: Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
