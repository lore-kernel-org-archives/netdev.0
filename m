From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Re : Re : Re : Bonding : Monitoring of 4965 wireless card
Date: Wed, 09 Jan 2008 15:26:38 -0800
Message-ID: <10541.1199921198@death>
References: <416779.67064.qm@web25704.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: patnel972-linux@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:44782 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbYAIX0k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 18:26:40 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m09NQemp028089
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 18:26:40 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09NQd6e106968
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 16:26:39 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09NQdJs020711
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 16:26:39 -0700
In-reply-to: <416779.67064.qm@web25704.mail.ukl.yahoo.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

patnel972-linux@yahoo.fr wrote:

>I mean that instead of arp test an ip in lan or else, i want it to tes=
t 127.0.0.1 but in order to do this it must go out and re-enter and the=
n use wlan0 to go out.

	In other words, what I think you're saying (and I'm not entirely
sure here) is that you want probes to go to a remote node on the
network, and back, without having to actually know the identity of the
remote node (because, presumably, on a roaming type of wireless
configuration, your gateway and whatnot can change from time to time).

	Is that what you're looking for?

	That isn't available now, but might be straightforward to plug
into the address update system to keep the arp_ip_target up to date as
the current gateway as the gateway changes.  I haven't looked into the
details of doing that, but in theory it sounds straightforward.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


>
>----- Message d'origine ----
>De : Jay Vosburgh <fubar@us.ibm.com>
>=C3=80 : patnel972-linux@yahoo.fr
>Cc : John W. Linville <linville@tuxdriver.com>; netdev@vger.kernel.org
>Envoy=C3=A9 le : Mercredi, 9 Janvier 2008, 22h36mn 00s
>Objet : Re: Re : Re : Bonding : Monitoring of 4965 wireless card=20
>
>patnel972-linux@yahoo.fr wrote:
>
>>I ignore it, but it seems like it prevent bonding detect link of
> wlan0. I enslave wlan0 and i already use use_carrier=3D1;
>
>    The default for bonding is use_carrier=3D1, which makes bonding
>use the device driver's netif_carrier_on/off state for link detection.
>Bonding only checks via ethtool/mii if use_carrier=3D0.
>
>>I'll try arp monitoring but this is annoying i c'ant test localhost.
> Is there a way to test localhost with arp, without pass through lo ?=20
>
>    What do you mean by "test localhost with arp, without pass
>through lo"?  ARP monitoring issues probes (ARPs) to a remote
>destination to confirm that there is connectivity; I'm not sure what
>localhost has to do with it.
>
>    In general, though, I have not tested bonding with wireless
>adapters, so I'm unfamiliar with how well it does or does not work.
>
>    -J
>
>---
>    -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
>
>
>
>
>      ________________________________________________________________=
_____________=20
>Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo=
! Mail http://mail.yahoo.fr
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
