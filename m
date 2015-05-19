From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] tcp: add rfc3168, section 6.1.1.1. fallback
Date: Tue, 19 May 2015 16:54:00 -0400 (EDT)
Message-ID: <20150519.165400.818177627516799715.davem@davemloft.net>
References: <cc0be24818d7009208dd0d8f73cc35939957f134.1432059419.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fw@strlen.de,
	mirja.kuehlewind@tik.ee.ethz.ch, trammell@tik.ee.ethz.ch,
	edumazet@google.com, dave.taht@gmail.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbESUyC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:54:02 -0400
In-Reply-To: <cc0be24818d7009208dd0d8f73cc35939957f134.1432059419.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 19 May 2015 21:33:42 +0200

> This work as a follow-up of commit f7b3bec6f516 ("net: allow setting =
ecn
> via routing table") and adds RFC3168 section 6.1.1.1. fallback for ou=
tgoing
> ECN connections. In other words, this work adds a retry with a non-EC=
N
> setup SYN packet, as suggested from the RFC on the first timeout:
>=20
>   [...] A host that receives no reply to an ECN-setup SYN within the
>   normal SYN retransmission timeout interval MAY resend the SYN and
>   any subsequent SYN retransmissions with CWR and ECE cleared. [...]
 ...
> Reference: https://www.ietf.org/proceedings/92/slides/slides-92-iccrg=
-1.pdf
> Reference: https://www.ietf.org/proceedings/89/slides/slides-89-tsvar=
ea-1.pdf
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Mirja K=FChlewind <mirja.kuehlewind@tik.ee.ethz.ch>
> Signed-off-by: Brian Trammell <trammell@tik.ee.ethz.ch>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Dave T=E4ht <dave.taht@gmail.com>
> ---
>  v2 -> v3:
>   - Very sorry. Typo happened in Dave's name since v1, getting it rig=
ht
>     this time, no bad intentions. ;)
>  v1 -> v2:
>   - Added suggestion from Eric to let ecn_flags be cleared eventually=
 in
>     tcp_ecn_rcv_synack(), thanks!
>   - Rest as is.

Applied, thanks everyone.
