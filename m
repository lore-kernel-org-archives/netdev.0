From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix bug of update IPv4 PMTU when received ICMP Fragmentation Needed message
Date: Mon, 4 Jun 2007 14:14:06 +1000
Message-ID: <20070604041406.GA28263@gondor.apana.org.au>
References: <E1HuRAd-0002Wl-00@gondolin.me.apana.org.au> <46635F39.2090009@cn.fujitsu.com> <20070604025528.GA27750@gondor.apana.org.au> <46638F2D.90608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2962 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751508AbXFDEOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 00:14:08 -0400
Content-Disposition: inline
In-Reply-To: <46638F2D.90608@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 04, 2007 at 12:03:57PM +0800, Wei Yongjun wrote:
>
> So I want to know how the route announce a MTU larger then 576, such as 
> 1280? RFC says ICMP error message return as much as we can without 
> exceeding 576 bytes.

I think there is a misunderstanding here.  The RFC is talking about
how much of the payload may be included in the ICMP packet.  It is
not talking about the length field in the original IP header.  That
must be left untouched.

> And ipv4 router alaways return as a packet size 576 because of this.
> If MTU is greater then 576, HOST will used "mtu = guess_mtu(old_mtu)" to 
> get a MTU. Method of send ICMP Fragmentation Needed message is 
> difference from receive,

Which router is doing that?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
