From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: RFC 5961 5.2 Blind Data Injection Attack
 Mitigation
Date: Mon, 22 Oct 2012 15:11:31 -0400 (EDT)
Message-ID: <20121022.151131.792891680432322007.davem@davemloft.net>
References: <1350885431.8609.250.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	hkchu@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab2JVTLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 15:11:36 -0400
In-Reply-To: <1350885431.8609.250.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Oct 2012 07:57:11 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> RFC 5961 5.2 [Blind Data Injection Attack].[Mitigation]
> 
>   All TCP stacks MAY implement the following mitigation.  TCP stacks
>   that implement this mitigation MUST add an additional input check to
>   any incoming segment.  The ACK value is considered acceptable only if
>   it is in the range of ((SND.UNA - MAX.SND.WND) <= SEG.ACK <=
>   SND.NXT).  All incoming segments whose ACK value doesn't satisfy the
>   above condition MUST be discarded and an ACK sent back.
> 
> Move tcp_send_challenge_ack() before tcp_ack() to avoid a forward
> declaration.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
