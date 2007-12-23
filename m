From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about
	MAC address change
Date: Sun, 23 Dec 2007 08:17:52 -0500
Message-ID: <1198415873.4423.96.camel@localhost>
References: <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
	 <20071223.213841.108421688.yoshfuji@linux-ipv6.org>
	 <1198413975.4423.65.camel@localhost>
	 <20071223.220447.56355925.yoshfuji@linux-ipv6.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dshwatrz@gmail.com, davem@davemloft.net, netdev@vger.kernel.org,
	kaber@trash.net
To: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:19069 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbXLWNR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 08:17:57 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1948679wah.23
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2007 05:17:57 -0800 (PST)
In-Reply-To: <20071223.220447.56355925.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2007-23-12 at 22:04 +0900, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E wrote:

> If the secondary MACs are used with ARP/NDP, we should take care of
> that, but I think we use the primary MAC for ARP/NDP, no?
> (In other words, we always use primary MAC for ARP reply / NA, no?)

I think it maybe a policy decision;=20
In the IPV4 case, where the system owns the IP addresses for the
classical scenario where there is a single MAC address per ethx then we
always respond with MAC address of ethx wherever the arp request was
received from. I think it is different in the case of IPV6 where the et=
h
device owns the IP address, no? i.e is that where you are drawing the
concept of primary MAC?
The case of multiple MACs per interface requires further policy
resolution IMO. It would be nice to be able to tell the kernel which MA=
C
to use when responding for which ip address it owns. This can be then
easily mapped to the routing table src address selection.
Patrick?

cheers,
jamal



