From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Tue, 11 Jul 2006 18:51:31 -0700 (PDT)
Message-ID: <20060711.185131.10796208.davem@davemloft.net>
References: <20060708.133223.35527292.davem@davemloft.net>
	<002201c6a554$e6af4580$4710100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59876
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932323AbWGLBuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 21:50:44 -0400
To: ravinandan.arakali@neterion.com
In-Reply-To: <002201c6a554$e6af4580$4710100a@pc.s2io.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Date: Tue, 11 Jul 2006 18:45:48 -0700

> tk = tcp_sk(skb->sk);
> if (tk->ecn_flags & TCP_ECN_OK)
>    /* Check CE, ECE, CWR etc */
> 
> I find that skb->sk is NULL. Is this the correct way to check the
> per-session
> ECN capability ? Why is skb->sk NULL ?

On receive?  There is no reason for skb->sk to be anything other than
NULL on receive, the networking stack hasn't even seen the packet yet.
Only the driver has seen the skb.
