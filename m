From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix bug of update IPv4 PMTU when received ICMP Fragmentation Needed message
Date: Mon, 4 Jun 2007 12:55:28 +1000
Message-ID: <20070604025528.GA27750@gondor.apana.org.au>
References: <E1HuRAd-0002Wl-00@gondolin.me.apana.org.au> <46635F39.2090009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2799 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751179AbXFDCza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2007 22:55:30 -0400
Content-Disposition: inline
In-Reply-To: <46635F39.2090009@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 04, 2007 at 08:39:21AM +0800, Wei Yongjun wrote:
>
> >Huh? The test new_mtu >= old_mtu should only hold if the sending router
> >is buggy which is what the hack is for.
>
> Note here old_mtu is not the real old mtu, is the received message's size:
>  unsigned short old_mtu = ntohs(iph->tot_len);
> So maybe the patch would like following.

The size of the packet that caused the ICMP is what we want here.  That's
why the router must be buggy.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
