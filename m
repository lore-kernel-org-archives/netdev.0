From: "Sumit Pandya" <sumit@elitecore.com>
Subject: RE: Do you know the TCP stack? (127.x.x.x routing)
Date: Mon, 7 Mar 2005 12:31:57 +0530
Message-ID: <HGEFKOBCHAIJDIEJLAKDCEBGCBAA.sumit@elitecore.com>
References: <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=Windows-1252
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
To: "Zdenek Radouch" <zdenek@rcn.com>
In-Reply-To: <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zdenek,
	I don't know how much help you can get with "dummy" interface. Try to set
your requirement with that special interface into mind.
-- Sumit

> -----Original Message-----
> From: linux-net-owner@vger.kernel.org
> [mailto:linux-net-owner@vger.kernel.org]On Behalf Of Zdenek Radouch
> Sent: Monday, March 07, 2005 3:21 AM

>
> OK.  We've gone a full circle, [except for a few digressions
> along the lines of me not knowing that while the rest of the
> world still uses 'route', under linux it has long been deprecated]
> you seem to be agreeing with my original guess that
> subnetting the 127 net may not be trivial, and that it may require
> some kernel hacking.
>
> So my original questions still stand:
>
> 1) How could one remove the special kernel treatment of the 127 net?
>     [so that "lo" gets 127.0.0.1/16 and "foo" gets 127.1.0.1/16, and
>     so that the "foo" interface can actually receive packets?
>
> 2) If it does require kernel hacking, would you like to do it for me?
>     (as I had said, as a contract)
>
>
> >> it won't accept outside packets with a loopback address.
>
> Not accepting packets with with a loopback address is one
> thing, not accepting any 127.0.0.0/8 packets is entirely something else.
>
> Couldn't that whole 127 thing be ripped out of the kernel?
> Why couldn't the "lo" interface be treated as any other interface?

