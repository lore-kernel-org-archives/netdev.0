From: Roy Sigurd Karlsbakk <roy@karlsbakk.net>
Subject: Re: Adding ND to bonding?
Date: Tue, 4 Jun 2013 11:33:56 +0200 (CEST)
Message-ID: <11265301.16.1370338436286.JavaMail.root@zimbra>
References: <10725.1370292786@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.karlsbakk.net ([213.236.233.66]:38278 "EHLO
	zimbra.karlsbakk.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab3FDJeF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 05:34:05 -0400
In-Reply-To: <10725.1370292786@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Roy Sigurd Karlsbakk <roy@karlsbakk.net> wrote:
> [...]
> >We're hoping one day we can move to an IPv6-only network (with some
> >gatewaying to IPv4 land), and I wonder if it would be hard to add
> >Neighbor Discovery Protocol to bonding as to allow for bonding on
> >ipv6. I'm not much of a kernel coder, but for what I could see, it
> >looks
> >doable.
>=20
> I haven't tested it lately, but I'm reasonably sure that ND runs
> over bonding. Is there something specific you have in mind here?

Perhaps I was a bit unclear about this. What I mean, is that in the act=
ive-backup mode, the method of finding whether or not a link is active,=
 is to send an ARP request to some machine, in my case, the gateway. Th=
is won't work with an IPv6-only configuration, since there's no ARP the=
re, only ND. For active-backup mode to work in IPv6, there needs to be =
added an ND mode, replacing or supplementing ARP.

Vennlige hilsener / Best regards

roy
--
Roy Sigurd Karlsbakk
(+47) 98013356
roy@karlsbakk.net
http://blogg.karlsbakk.net/
GPG Public key: http://karlsbakk.net/roysigurdkarlsbakk.pubkey.txt
--
I all pedagogikk er det essensielt at pensum presenteres intelligibelt.=
 Det er et element=C3=A6rt imperativ for alle pedagoger =C3=A5 unng=C3=A5=
 eksessiv anvendelse av idiomer med xenotyp etymologi. I de fleste tilf=
eller eksisterer adekvate og relevante synonymer p=C3=A5 norsk.
