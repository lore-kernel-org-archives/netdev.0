From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/route: enforce hoplimit max value
Date: Sat, 14 May 2016 15:34:55 -0400 (EDT)
Message-ID: <20160514.153455.805172777482220210.davem@davemloft.net>
References: <4a951826f558b10f62ce4338cb2620b6fc886ba5.1463154659.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49054 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbcENTe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 15:34:57 -0400
In-Reply-To: <4a951826f558b10f62ce4338cb2620b6fc886ba5.1463154659.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri, 13 May 2016 18:33:41 +0200

> Currently, when creating or updating a route, no check is performed
> in both ipv4 and ipv6 code to the hoplimit value.
> 
> The caller can i.e. set hoplimit to 256, and when such route will
>  be used, packets will be sent with hoplimit/ttl equal to 0.
> 
> This commit adds checks for the RTAX_HOPLIMIT value, in both ipv4
> ipv6 route code, substituting any value greater than 255 with 255.
> 
> This is consistent with what is currently done for ADVMSS and MTU
> in the ipv4 code.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks for fixing this.
