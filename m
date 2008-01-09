From: patnel972-linux@yahoo.fr
Subject: Re : Re : Re : Bonding : Monitoring of 4965 wireless card
Date: Wed, 9 Jan 2008 21:52:39 +0000 (GMT)
Message-ID: <416779.67064.qm@web25704.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web25704.mail.ukl.yahoo.com ([217.12.10.176]:43012 "HELO
	web25704.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750764AbYAIVwl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 16:52:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I mean that instead of arp test an ip in lan or else, i want it to test=
 127.0.0.1 but in order to do this it must go out and re-enter and then=
 use wlan0 to go out.


----- Message d'origine ----
De : Jay Vosburgh <fubar@us.ibm.com>
=C0 : patnel972-linux@yahoo.fr
Cc : John W. Linville <linville@tuxdriver.com>; netdev@vger.kernel.org
Envoy=E9 le : Mercredi, 9 Janvier 2008, 22h36mn 00s
Objet : Re: Re : Re : Bonding : Monitoring of 4965 wireless card=20

patnel972-linux@yahoo.fr wrote:

>I ignore it, but it seems like it prevent bonding detect link of
 wlan0. I enslave wlan0 and i already use use_carrier=3D1;

    The default for bonding is use_carrier=3D1, which makes bonding
use the device driver's netif_carrier_on/off state for link detection.
Bonding only checks via ethtool/mii if use_carrier=3D0.

>I'll try arp monitoring but this is annoying i c'ant test localhost.
 Is there a way to test localhost with arp, without pass through lo ?=20

    What do you mean by "test localhost with arp, without pass
through lo"?  ARP monitoring issues probes (ARPs) to a remote
destination to confirm that there is connectivity; I'm not sure what
localhost has to do with it.

    In general, though, I have not tested bonding with wireless
adapters, so I'm unfamiliar with how well it does or does not work.

    -J

---
    -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com





      _________________________________________________________________=
____________=20
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo!=
 Mail http://mail.yahoo.fr
