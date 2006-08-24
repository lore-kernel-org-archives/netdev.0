From: Andy Gay <andy@andynet.net>
Subject: Re: ProxyARP and IPSec
Date: Wed, 23 Aug 2006 22:20:43 -0400
Message-ID: <1156386043.7302.773.camel@tahini.andynet.net>
References: <44EBA1FC.5000801@zytor.com>	<20060823191425.GK3470@postel.suug.ch>
	<20060823.151424.78711856.davem@davemloft.net>
	<20060823231812.GA32394@ms2.inr.ac.ru> <44ECFCF1.10500@zytor.com>
	<44ECFD5F.6060901@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:62912 "EHLO
	vms040pub.verizon.net") by vger.kernel.org with ESMTP
	id S1030209AbWHXCU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:20:58 -0400
Received: from andyhp.tranquilitynj.net ([141.150.86.245])
 by vms040.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
 with ESMTPA id <0J4H00D83D6O45WC@vms040.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 23 Aug 2006 21:20:49 -0500 (CDT)
In-reply-to: <44ECFD5F.6060901@zytor.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-23 at 18:14 -0700, H. Peter Anvin wrote:
> H. Peter Anvin wrote:
> > Alexey Kuznetsov wrote:
> >>
> >> The question is where is this host really?
> >>
> >> If it is far far away and connected only via IPsec tunnel with 
> >> destionation
> >> of tunnel different of host address
> >>
> >> ip ro add THEHOST dev dummy0
> >>
> >> should be enough. It asserts that THEHOST is not on eth0.
> >> IPsec policy will figure out correct route, unless something is broken.
> >>
> > 
> > Just tried it, and it works as advertised.
> > 
> 
> ... except that OpenSwan will rip out the route and install a route 
> pointing to eth0, thus breaking the thing again.

Use a custom updown script with Openswan to fix that.

> 
> 	-hpa
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

