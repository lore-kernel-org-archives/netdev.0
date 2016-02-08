From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] net: fec: Add "phy-reset-active-low" property to DT
Date: Mon, 8 Feb 2016 22:51:38 +0100
Message-ID: <20160208215138.GB13673@lunn.ch>
References: <1454962873-1941-1-git-send-email-bernhard@bwalle.de>
 <3171793.SonfZDNmtV@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernhard Walle <bernhard-X9USDgGjgfuzQB+pC5nmwQ@public.gmane.org>, fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3171793.SonfZDNmtV@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 08, 2016 at 10:46:42PM +0100, Arnd Bergmann wrote:
> On Monday 08 February 2016 21:21:13 Bernhard Walle wrote:
> > We need that for a custom hardware that needs the reverse reset
> > sequence.
> > 
> > Signed-off-by: Bernhard Walle <bernhard-X9USDgGjgfuzQB+pC5nmwQ@public.gmane.org>
> > 
> 
> Why can't this be specified in the gpios property?

Backwards compatibility. The flag has always been ignored until now,
yet various DTs have a flag value which are active low. If suddenly it
worked, various boards would break :-(

       Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
