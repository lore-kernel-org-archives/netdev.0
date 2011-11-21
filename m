From: Albert Chin <linux-netdev@mlists.thewrittenword.com>
Subject: Re: Problems with dropped packets on bonded interface for 3.x
 kernels
Date: Mon, 21 Nov 2011 02:08:12 -0600
Message-ID: <20111121080811.GB7596@china>
References: <20111121051603.GB3702@china>
 <1321857123.17419.2.camel@edumazet-laptop>
 <20111121074453.GA7596@china>
 <1321862549.17419.12.camel@edumazet-laptop>
Reply-To: netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.thewrittenword.com ([69.67.212.77]:63397 "EHLO
	mail1.thewrittenword.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414Ab1KUIIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 03:08:13 -0500
Received: from mail1.il.thewrittenword.com (emma-internal-gw.il.thewrittenword.com [192.168.13.25])
	by mail1.thewrittenword.com (Postfix) with ESMTP id C92D95C17
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 08:43:15 +0000 (UTC)
Received: from china.thewrittenword.com (danger-gw.il.thewrittenword.com [10.191.57.254])
	by mail1.il.thewrittenword.com (Postfix) with ESMTP id E65866E1
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 08:08:12 +0000 (UTC)
Content-Disposition: inline
In-Reply-To: <1321862549.17419.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2011 at 09:02:29AM +0100, Eric Dumazet wrote:
> Le lundi 21 novembre 2011 =E0 01:44 -0600, Albert Chin a =E9crit :
>=20
> > So only "unknown" protocols are dropped? I just ran tcpdump for 96
> > packets and inspected the output. The only packets received are LAC=
P,
> > ARP, STP (Spanning Tree Protocol), DTP (Dynamic Trunking Protocol).
> > How are these "unknown"?
>=20
> No protocol handler is setup to analyze some them in your box.
>=20
> (ARP is handled of course)
>=20
> Like if you receive IPv6 packets while IPv6 was not compiled/loaded i=
nto
> your kernel.
>=20
> Nothing you have to worry about. We receive plenty of unknown packets
> these days...

Ok. If the above is the case though, I should see dropped packets on
all of my interfaces. But, I only see it on the bonded interface.
Kinda odd.

Thanks.

--=20
albert chin (china@thewrittenword.com)
