From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Tue, 13 Jan 2015 14:22:35 -0500 (EST)
Message-ID: <20150113.142235.1647397796492702755.davem@davemloft.net>
References: <1421055040-8732-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ncardwell@google.com, ycheng@google.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, gregory.detal@uclouvain.be,
	nanditad@google.com
To: sebastien.barre@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbbAMTWi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 14:22:38 -0500
In-Reply-To: <1421055040-8732-1-git-send-email-sebastien.barre@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: S=E9bastien Barr=E9 <sebastien.barre@uclouvain.be>
Date: Mon, 12 Jan 2015 10:30:40 +0100

> With TLP, the peer may reply to a probe with an
> ACK+D-SACK, with ack value set to tlp_high_seq. In the current code,
> such ACK+DSACK will be missed and only at next, higher ack will the T=
LP
> episode be considered done. Since the DSACK is not present anymore,
> this will cost a cwnd reduction.
>=20
> This patch ensures that this scenario does not cause a cwnd reduction=
, since
> receiving an ACK+DSACK indicates that both the initial segment and th=
e probe
> have been received by the peer.
>=20
> The following packetdrill test, from Neal Cardwell, validates this pa=
tch:
 ...
> Credits:
> -Gregory helped in finding that tcp_process_tlp_ack was where the cwn=
d
> got reduced in our MPTCP tests.
> -Neal wrote the packetdrill test above
> -Yuchung reworked the patch to make it more readable.
>=20
> Cc: Gregory Detal <gregory.detal@uclouvain.be>
> Cc: Nandita Dukkipati <nanditad@google.com>
> Tested-by: Neal Cardwell <ncardwell@google.com>
> Reviewed-by: Yuchung Cheng <ycheng@google.com>
> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: S=E9bastien Barr=E9 <sebastien.barre@uclouvain.be>

Applied, thanks everyone.
