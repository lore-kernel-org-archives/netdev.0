From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/5] Add support for software UDP
 fragmentation offload(UFO)
Date: Sun, 12 Jul 2009 14:39:42 -0700 (PDT)
Message-ID: <20090712.143942.73393103.davem@davemloft.net>
References: <1247162981.8649.89.camel@w-sridhar.beaverton.ibm.com>
	<20090710010405.GA32639@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50548
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751138AbZGLVji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 17:39:38 -0400
In-Reply-To: <20090710010405.GA32639@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 10 Jul 2009 09:04:05 +0800

> On Thu, Jul 09, 2009 at 11:09:41AM -0700, Sridhar Samudrala wrote:
>> The following set of patches fixes support for UDP fragmentation offload
>> in the core networking stack to send/receive large UDP packets over UFO
>> enabled devices and fallback to software UFO when the outgoing device 
>> doesn't support UFO.
>> These patches enable setting UFO on virtio-net and tap devices and allow
>> large UDP packets to be sent between guest to host and inter guest under
>> KVM.
>> 
>> [PATCH net-next-2.6 1/5] udpv4: Handle large incoming UDP/IPv4 packets and support software UFO.
>> [PATCH net-next-2.6 2/5] udpv6: Fix HW checksum support for outgoing UFO packets
>> [PATCH net-next-2.6 3/5] udpv6: Fix gso_size setting in ip6_ufo_append_data
>> [PATCH net-next-2.6 4/5] udpv6: Remove unused skb argument of ipv6_select_ident()
>> [PATCH net-next-2.6 5/5] udpv6: Handle large incoming UDP/IPv6 packets and support software UFO
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good to me, all applied, thanks!
