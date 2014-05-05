From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8 v4] net: Checksum offload changes
Date: Mon, 05 May 2014 15:29:42 -0400 (EDT)
Message-ID: <20140505.152942.999944798547083202.davem@davemloft.net>
References: <alpine.DEB.2.02.1405021526150.19170@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbaEET3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 15:29:45 -0400
In-Reply-To: <alpine.DEB.2.02.1405021526150.19170@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 2 May 2014 16:27:44 -0700 (PDT)

> I am working on overhauling RX checksum offload. Goals of this effort
> are:
> 
> - Specify what exactly it means when driver returns CHECKSUM_UNNECESSARY
> - Preserve CHECKSUM_COMPLETE through encapsulation layers
> - Don't do skb_checksum more than once per packet
> - Unify GRO and non-GRO csum verification as much as possible
> - Unify the checksum functions (checksum_init)
> - Simply code
> 
> What is in this first patch set:
> 
> - Create a common "checksum_init" function which is called from
>   TCPv{4,6} and UDPv{4,6}
> - Add some for RFC6936, UDP/IPv6 zero checksums
> - Add architecture support for csum_add and provide implementations
>   for x86_64 and Sparc 32 and 64 bit (please test the latter)
> 
> Please review carefully and test if possible, mucking with basic
> checksum functions is always a little precarious :-)

This looks really good to me, thanks for integrating all the feedback
and following up.

Series applied to net-next, thanks.
