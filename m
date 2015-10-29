From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [BUG] Any-IP IPv6 support broken
Date: Thu, 29 Oct 2015 20:09:42 +0100
Message-ID: <1446145782.493380.423921913.1E80CAD4@webmail.messagingengine.com>
References: <0977189F-9778-4D1C-939D-FAD71595E5F6@gmail.com>
 <1446143957.486796.423892137.12302CDB@webmail.messagingengine.com>
 <E3F3A24A-F483-4026-97E5-B49F65AD2493@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Gilberto Bertin <gilberto.bertin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41970 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757264AbbJ2TJn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 15:09:43 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id E2EF62067F
	for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 15:09:42 -0400 (EDT)
In-Reply-To: <E3F3A24A-F483-4026-97E5-B49F65AD2493@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, Oct 29, 2015, at 19:58, Gilberto Bertin wrote:
>=20
> > On 29 Oct 2015, at 18:39, Hannes Frederic Sowa <hannes@stressindukt=
ion.org> wrote:
> >=20
> > Try the loopback interface:
> >=20
> > ip -6 route add local abcd:abcd:abcd:abcd::/64 dev *lo*
> >=20
> > Otherwise packets should end up in neighbor subsystem and you don't=
 want
> > that, still. ;)
> >=20
>=20
> Thanks for the reply.
>=20
> I know it=E2=80=99s working on the lo interface, but unluckily I need=
 it on
> other interfaces (and aliasing lo is not an option).
>=20
> Moreover:
> - the IPv6 patch explicitly refers to the possibility to do this with
>   eth0 interface (i.e. it's not a lo-only feature)
> - should it be consistent with the IPv4 behaviour? (or maybe it's not
>   supposed to work even with IPv4 addresses, and so this is a bug)

The routing commands won't automatically enable the ndisc layer to
answer neighbour discovery requests for that. The rule thing should wor=
k
but your clients somehow need to route all packets over the box with th=
e
"anyip" route setup.

Bye,
Hannes
