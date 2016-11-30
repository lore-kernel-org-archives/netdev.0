From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v3 0/4] Fix OdroidC2 Gigabit Tx link issue
Date: Tue, 29 Nov 2016 19:38:53 -0500 (EST)
Message-ID: <20161129.193853.827524417068912706.davem@davemloft.net>
References: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        andrew-g2DYL2Zd6BY@public.gmane.org, narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480326409-25419-1-git-send-email-jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Date: Mon, 28 Nov 2016 10:46:45 +0100

> This patchset fixes an issue with the OdroidC2 board (DWMAC + RTL8211F).
> The platform seems to enter LPI on the Rx path too often while performing
> relatively high TX transfer. This eventually break the link (both Tx and
> Rx), and require to bring the interface down and up again to get the Rx
> path working again.
> 
> The root cause of this issue is not fully understood yet but disabling EEE
> advertisement on the PHY prevent this feature to be negotiated.
> With this change, the link is stable and reliable, with the expected
> throughput performance.
> 
> The patchset adds options in the generic phy driver to disable EEE
> advertisement, through device tree. The way it is done is very similar
> to the handling of the max-speed property.

Patches 1-3 applied to net-next, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
