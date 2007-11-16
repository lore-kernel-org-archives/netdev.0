From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Fri, 16 Nov 2007 12:11:53 +0800
Message-ID: <E1IssYb-0000KG-00@gondolin.me.apana.org.au>
References: <473D0BF8.3060902@cn.fujitsu.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com (Wang Chen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2953 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755171AbXKPEMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 23:12:05 -0500
In-Reply-To: <473D0BF8.3060902@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wang Chen <wangchen@cn.fujitsu.com> wrote:
>
> So, I think the checksum in udp_queue_rcv_skb() actually does
> the work, not that in udp_recvmsg() and udp_poll().
> 
> If I am wrong, please point out.

We may have a bug in the accounting area.  Check the recent
patch made to UDP/IPv6 which is probably needed here as well.

Hmm, we really need to spend more time on merging stuff between
IPv4 and IPv6 to save all this duplication of effort.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
