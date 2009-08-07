From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [evb] RE: [PATCH][RFC] net/bridge: add basic VEPA support
Date: Fri, 7 Aug 2009 14:36:52 -0700
Message-ID: <20090807143652.1659ac57@nehalam>
References: <D2E118A1E7268F449C469EA2F301D92902BC39B2@exil.voltaire.com>
	<000001ca17a3$03f841f0$0be8c5d0$@edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <anna.fischer@hp.com>, <bridge@lists.linux-foundation.org>,
	<netdev@vger.kernel.org>,
	<virtualization@lists.linux-foundation.org>, <davem@davemloft.net>,
	<kaber@trash.net>, <adobriyan@gmail.com>, <arnd@arndb.de>
To: "Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37127 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752282AbZHGVhZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2009 17:37:25 -0400
In-Reply-To: <000001ca17a3$03f841f0$0be8c5d0$@edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Aug 2009 14:06:58 -0700
"Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu> wrote:

> Yaron,
>=20
>=20
> The interface multiplexing can be achieved using macvlan driver or us=
ing an SR-IOV capable NIC (the preferred option), macvlan may need to b=
e extended to support VEPA multicast handling, this looks like a rather=
 simple task=20
>=20
> Agreed that the hardware solution is preferred so the macvlan impleme=
ntation doesn=E2=80=99t really matter.  If we are talking SR-IOV, then =
it is direct mapped, regardless of whether there is a VEB or VEPA in th=
e hardware below, so you are bypassing the bridge software code also. =20
>=20
> I disagree that adding the multicast handling is simple =E2=80=93 whi=
le not conceptually hard, it will basically require you to put an addre=
ss table into the macvlan implementation =E2=80=93 if you have that, th=
en why not have just used the one already in the bridge code.  If you h=
ook a VEPA up to a non-hairpin mode external bridge, you get the macvla=
n capability as well.

I have a patch that forwards all multicast packets, and another that do=
es
proper forwarding. It should have worked that way in original macvlan, =
the
current behavior is really a bug.


--=20
