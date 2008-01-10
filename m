From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: ipip tunnel code (IPV4)
Date: Thu, 10 Jan 2008 09:58:50 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDD92@XCH-NW-7V2.nw.nos.boeing.com>
References: <147a89290801100634t7854a101w203de150982b0284@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: "Andy Johnson" <johnsonzjo@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:56709 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755958AbYAJSmE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 13:42:04 -0500
Content-class: urn:content-classes:message
In-Reply-To: <147a89290801100634t7854a101w203de150982b0284@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy,

> -----Original Message-----
> From: Andy Johnson [mailto:johnsonzjo@gmail.com] 
> Sent: Thursday, January 10, 2008 6:35 AM
> To: netdev@vger.kernel.org
> Subject: ipip tunnel code (IPV4)
> 
> Hello,
> 
> I am trying to learn the IPV4 ipip tunnel code  (net/ipv4/ipip.c)
> and I have two little questions about
> semantics of variables:
> 
> ipip_fb_tunnel_init - what does "fb" stand for ?
> 
> In tunnels_wc   : what does "wc" stand for ?

Similar names occur in net/ipv6/sit.c, which is the
IPv6-in-IPv4 analog of ipip.c. I am 90% certain that
"wc" stands for "wildcard" - it is used for selecting
the default tunnel interface when no other tunnel
interfaces match a specific (src, dst) pair.

In that light, I assume "fb" stands for something like
"fallback" although I am not certain. It would seem to
fit though, because the "fallback" tunnel interface is
the one that is selected by a "wildcard" match.

Would be interested if anyone could confirm or correct
my assumptions.

Thanks - Fred
fred.l.templin@boeing.com 
 
> Regards,
> Andy
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
