From: "Jean-Philippe RAMES" <jprames@ags-backup.com>
Subject: RE: Traffic Control - Burst 4096Mb ?!
Date: Wed, 18 Jun 2008 12:28:51 +0200
Message-ID: <BD53B6560CD66B4AA230BBB09CD2C8F346DB94@ags-exch.ags-intranet.net>
References: <BD53B6560CD66B4AA230BBB09CD2C8F3244275@ags-exch.ags-intranet.net> <BD53B6560CD66B4AA230BBB09CD2C8F346DB91@ags-exch.ags-intranet.net> <4858E2CE.5020605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.ags-backup.com ([195.101.79.129]:23980 "EHLO
	exchange.ags-backup.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbYFRK3c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 06:29:32 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4858E2CE.5020605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iproute2-ss070313

-----Message d'origine-----
De=A0: Patrick McHardy [mailto:kaber@trash.net]=20
Envoy=E9=A0: mercredi 18 juin 2008 12:26
=C0=A0: Jean-Philippe RAMES
Cc=A0: netdev@vger.kernel.org
Objet=A0: Re: Traffic Control - Burst 4096Mb ?!

Jean-Philippe RAMES wrote:
> Hello,
> =20
> I don't understand why when I run:
> tc class add dev eth2 parent 2:1 classid 2:85 htb rate 1024bit ceil
> 1mbit burst 30kb prio 5
>=20
> the burst becomes 4096Mb (tc class show eth2):
> class htb 2:85 parent 2:1 prio 5 rate 1024bit ceil 1000Kbit burst 409=
6Mb
> cburst 2100b
>=20
> And I've noticed if I run the same command with a different rate:
> tc class add dev eth2 parent 2:1 classid 2:85 htb rate 256kbit ceil
> 1mbit burst 30kb prio 5
>=20
> the 30kb burst appears correctly:
> class htb 2:85 parent 2:1 prio 5 rate 1024bit ceil 1000Kbit burst 30k=
b
> cburst 2100b

Which iproute version are you using?

