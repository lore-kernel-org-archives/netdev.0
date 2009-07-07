From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] ucc_geth: Add support for skb recycling
Date: Tue, 07 Jul 2009 11:47:38 -0700
Message-ID: <4A53984A.4050002@hp.com>
References: <20090707183842.GA8425@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:33195 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865AbZGGSrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 14:47:42 -0400
In-Reply-To: <20090707183842.GA8425@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> We can reclaim transmitted skbs to use in the receive path, so-called
> skb recycling support.
> 
> Also reorder ucc_geth_poll() steps, so that we'll clean tx ring firstly,
> thus maybe reclaim some skbs for rx.

Admittedly, all the world is not TCP, but a big chunk is, so are you likely to 
have reference counts go to zero on the tx queue for anything other than small 
standalone TCP ACK segments?

rick jones
