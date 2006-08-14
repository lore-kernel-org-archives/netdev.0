From: Andi Kleen <ak@suse.de>
Subject: Re: skb_shared_info()
Date: Mon, 14 Aug 2006 07:04:01 +0200
Message-ID: <200608140704.01533.ak@suse.de>
References: <20060808.163915.03600382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:49073 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751842AbWHNFEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 01:04:13 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060808.163915.03600382.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The e1000 issue is just one example of this, another
> would be any attempt to consolidate the TCP retransmit
> queue data management.

Another reason to move it in the sk_buff would be better cache 
coloring? Currently on large/small MTU packets it will be always on 
the same colors.

-Andi
