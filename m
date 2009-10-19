From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: reduce SYN-ACK retrans for TCP_DEFER_ACCEPT
Date: Mon, 19 Oct 2009 22:11:43 +0200
Message-ID: <4ADCC7FF.8030309@gmail.com>
References: <Pine.LNX.4.58.0910192302000.2971@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39529 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757416AbZJSULp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 16:11:45 -0400
In-Reply-To: <Pine.LNX.4.58.0910192302000.2971@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov a =E9crit :
> 	Change SYN-ACK retransmitting code for the TCP_DEFER_ACCEPT
> users to not retransmit SYN-ACKs during the deferring period if
> ACK from client was received. The goal is to reduce traffic
> during the deferring period. When the period is finished
> we continue with sending SYN-ACKs (at least one) but this time
> any traffic from client will change the request to established
> socket allowing application to terminate it properly.
> Also, do not drop acked request if sending of SYN-ACK fails.
>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

