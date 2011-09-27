From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next] tcp: unalias tcp_skb_cb flags and ip_dsfield
Date: Tue, 27 Sep 2011 10:37:38 +0300
Message-ID: <201109271037.38786.christoph.paasch@uclouvain.be>
References: <1316757739.2560.12.camel@edumazet-laptop> <1317103249.2796.25.camel@edumazet-laptop> <20110927.022025.1306291417181821045.davem@davemloft.net>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, hkchu@google.com,
	ilpo.jarvinen@helsinki.fi, jhs@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59699 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785Ab1I0Hho convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 03:37:44 -0400
In-Reply-To: <20110927.022025.1306291417181821045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I realize that before "struct tcp_skb_cb" is a comment saying that it's=
 44=20
bytes long.

However, (as far as I can see) before Eric's change it was 42 bytes lon=
g and=20
now it became 43 bytes.

Wouldn't it make sense to change the comment, so that it's consistent a=
gain=20
with the real size of tcp_skb_cb ?

Cheers,
Christoph



On Tuesday 27 September 2011 wrote David Miller:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 27 Sep 2011 08:00:49 +0200
>=20
> > struct tcp_skb_cb contains a "flags" field containing either tcp fl=
ags
> > or IP dsfield depending on context (input or output path)
> >=20
> > Introduce ip_dsfield to make the difference clear and ease maintena=
nce.
> > If later we want to save space, we can union flags/ip_dsfield
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, thanks Eric.
>=20
> > If there is no objection, I plan to rename "flags" to "tcp_flags" i=
n a
> > following patch.
>=20
> No objections.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
