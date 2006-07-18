From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Tue, 18 Jul 2006 20:19:34 +0200
Message-ID: <44BD2636.1010105@yahoo.fr>
References: <200607161120.k6GBKZEG009486@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sophia.inria.fr ([138.96.64.20]:7343 "EHLO sophia.inria.fr")
	by vger.kernel.org with ESMTP id S932343AbWGRSUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 14:20:55 -0400
To: chas3@users.sourceforge.net
In-Reply-To: <200607161120.k6GBKZEG009486@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

chas williams - CONTRACTOR wrote:
> why does the input side of the ip layer believe the cb contains valid
> data?  it should zero the contents of the cb, or just fill in the cb
> correctly when the packet arrives at its doorstop.
>   
Why not clearing the whole IPCB(skb) instead of
just IPCB(skb)->opts? that would also clear
IPCB(skb)->flags.

And, does not ipv6 need the same treatment with
IP6CB?

Regards.

-- 
Guillaume


