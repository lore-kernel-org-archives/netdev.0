From: patnel972-linux@yahoo.fr
Subject: Re : Re : Re : Re : Bonding : Monitoring of 4965 wireless card
Date: Thu, 10 Jan 2008 08:37:41 +0000 (GMT)
Message-ID: <722263.85774.qm@web25703.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web25703.mail.ukl.yahoo.com ([217.12.10.175]:47996 "HELO
	web25703.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752098AbYAJIhn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 03:37:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes it's what i'm looking for. I don't understand how to change the arp=
_ip_target with the gateway, arp_ip_target is a module option.


----- Message d'origine ----
De : Jay Vosburgh <fubar@us.ibm.com>
=C0 : patnel972-linux@yahoo.fr
Cc : netdev@vger.kernel.org
Envoy=E9 le : Jeudi, 10 Janvier 2008, 0h26mn 38s
Objet : Re: Re : Re : Re : Bonding : Monitoring of 4965 wireless card=20

patnel972-linux@yahoo.fr wrote:

>I mean that instead of arp test an ip in lan or else, i want it to
 test 127.0.0.1 but in order to do this it must go out and re-enter and
 then use wlan0 to go out.

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
>=C0 : patnel972-linux@yahoo.fr
>Cc : John W. Linville <linville@tuxdriver.com>; netdev@vger.kernel.org
>Envoy=E9 le : Mercredi, 9 Janvier 2008, 22h36mn 00s
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
>   =20
  _____________________________________________________________________=
________=20
>Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers
 Yahoo! Mail http://mail.yahoo.fr
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html





      _________________________________________________________________=
____________=20
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo!=
 Mail http://mail.yahoo.fr
