From: Martin Langer <martin-langer-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Fri, 9 Feb 2007 23:52:34 +0100
Message-ID: <20070209225234.GA3381@tuba>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net> <200702091811.40683.mb@bu3sch.de> <45CCF432.2070002@gentoo.org> <200702091829.51002.mb@bu3sch.de> <45CCBB93.2040703@lwfinger.net> <45CCC5DF.8010001@gentoo.org> <45CCCAE1.9080901@lwfinger.net> <20070209213239.GA11650@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Joseph Jezak <josejx-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070209213239.GA11650-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 09, 2007 at 09:32:39PM +0000, Matthew Garrett wrote:
> On Fri, Feb 09, 2007 at 01:26:25PM -0600, Larry Finger wrote:
> 
> > My plan is to continue to maintain bcm43xx-SoftMAC for at least the BPHY and 4306 revisions even
> > after d80211 becomes the in-kernel driver. Of course, I hope that we will have found the killer bugs
> > by that time, and that maintenance will only require following kernel API changes.
> 
> Just to make sure I'm understanding this correctly - does the v4 
> firmware drop compatibility for older cards, or is it just that Broadcom 
> dropped support in the driver at the same time as the firmware changed, 
> and the new firmware will still also drive the old cards?

We can't extract bcm43xx_microcode2.fw from v4 drivers. You need this 
file for old rev2+3 0x812 cores. So we don't know what firmware we 
should load into those old cores. I think broadcom never developed a new 
v4 style firmware for their old hardware.

Martin


-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
