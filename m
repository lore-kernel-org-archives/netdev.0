From: Rabin Vincent <rabin-66gdRtMMWGc@public.gmane.org>
Subject: Re: [PATCH] phy: remove irq param to fix crash in fixed_phy_add()
Date: Mon, 16 May 2016 15:11:35 +0200
Message-ID: <20160516131134.GA31094@lnxartpec.se.axis.com>
References: <1463397356-5656-1-git-send-email-rabin.vincent@axis.com>
 <20160516122903.GA27725@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rabin Vincent <rabin.vincent-VrBV9hrLPhE@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org,
	linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Rabin Vincent <rabinv-VrBV9hrLPhE@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160516122903.GA27725-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2016 at 02:29:03PM +0200, Andrew Lunn wrote:
> What i think is better is to make fixed_phy_add() return -EPROBE_DEFER
> if it is called before fixed_mdio_bus_init().

I don't see how this will work for platforms such as ar7 and bcm47xx
which call fixed_phy_add() from platform code.  There is no probe to
retry there so while the EPROBE_DEFER will certainly fix the crash it
will also leave the platforms without a phy.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
