From: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
Subject: Re: =?utf-8?B?0J7RgtCy0LXRgg==?=
	=?utf-8?Q?=3A?= [PATCH 10/10] ieee802154: add at86rf230/rf231 spi
	driver
Date: Tue, 2 Jun 2009 12:52:36 +0400
Message-ID: <20090602085236.GA13088@build.ossfans.org>
References: <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com> <69e28c910906010921r56cf7017gc858cb7ba819c385@mail.gmail.com> <20090601203348.GC7143@doriath.ww600.siemens.net> <200906021010.49613.hs4233@mail.mn-solutions.de> <1243930893.3192.62.camel@localhost.localdomain> <bc64b4640906020129x4fe15e5en9d8e2cad1d86b236@mail.gmail.com> <1243931809.3192.68.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Holger Schurig <hs4233-x6+DxXLjN1AJvtFkdXX2Hg4jNU5vUVPG@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?iso-8859-1?Q?G=E1bor?= Stefanik <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1243931809.3192.68.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 02, 2009 at 10:36:49AM +0200, Marcel Holtmann wrote:
> > This gonna happen, as we are most probably going to implement 6lowpan
> > on top of our stack. 6lowpan is a way to encapsulate IPv6 frames into
> > IEEE 802.15.4 and has nothing in common with ZigBee. Moreover
> > ZigBee is a trademark with strict rules upon it's usage. Our lawyers are
> > currently investigating if it's possible to use this name in projects like
> > Linux kernel which are open-source, non-related to any project but
> > OTOH can be encapsulated in any commercial project.
> > 
> > IEEE 802.15.4 is a term like IEEE 802.11. We do have mac80211,
> > we have had (until recently) ieee80211 dir, so why bother?
> > 
> > For Bluetooth naming directories 'bluetooth' is logical, as 802.15.1
> > standard is a less known name, doesn't incorporate latest changes
> > from Bluetooth, etc.
> 
> and so is IEEE 802.15.4 hence we propose using "zigbee" here. Using the
> mac80211 has historical reasons and 802.11 is a known name and even used
> on product marketing material. IEEE 802.15.4 is not. We are also using
> the term "wimax" and not its IEEE numbering.

That WILL add confusion. Because of the following:
1. IEEE 802.15.4 is layer under ZigBee. ZigBee is implemented on top of
IEEE 802.15.4, like UDP is implemented on top of IP.
2. There are hardware implementations of the following sorts:
a) Simple radio (IEEE 802.15.4 PHY).
b) IEEE 802.15.4 MAC
c) ZigBee, or other high level protocols (well, actually I don't know of
any others than ZigBee at this level, but that doesn't mean they don't
exist).

Using this stack we can implement both a) and b). With addition of
ZigBee layers, it might be possible to implement c), too. For things
like 6lowpan, only a) and b) are useful. If you call this all ZigBee,
it will add confusion and artifical limitation. Not to mention, not
true. And just for cosmetic measures. That will be a lot of trouble and
no practical gain from that.

References:
RFC-4919
RFC-4944

All the best,
S.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
