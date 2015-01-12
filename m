From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Mon, 12 Jan 2015 07:15:29 -0800
Message-ID: <1421075729.4099.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421055040-8732-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>, netdev@vger.kernel.org,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>
To: =?ISO-8859-1?Q?S=E9bastien_Barr=E9?= <sebastien.barre@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:38174 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbbALPPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 10:15:32 -0500
Received: by mail-qg0-f51.google.com with SMTP id i50so17951208qgf.10
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 07:15:31 -0800 (PST)
In-Reply-To: <1421055040-8732-1-git-send-email-sebastien.barre@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-01-12 at 10:30 +0100, S=C3=A9bastien Barr=C3=A9 wrote:
> With TLP, the peer may reply to a probe with an
> ACK+D-SACK, with ack value set to tlp_high_seq. In the current code,
> such ACK+DSACK will be missed and only at next, higher ack will the T=
LP
> episode be considered done. Since the DSACK is not present anymore,
> this will cost a cwnd reduction.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks guys.
