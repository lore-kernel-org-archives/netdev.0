From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] net: Checksum offload changes - Part II
Date: Thu, 08 May 2014 23:48:27 -0400 (EDT)
Message-ID: <20140508.234827.771833499800031850.davem@davemloft.net>
References: <alpine.DEB.2.02.1405071642040.858@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161AbaEIDs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 23:48:29 -0400
In-Reply-To: <alpine.DEB.2.02.1405071642040.858@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 7 May 2014 16:51:33 -0700 (PDT)

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
> What is in this second patch set:
> 
> - Call common inet checksum validation functions in ICMP{4,6},
>   GRE{4,6}, and IGMP.
> - In UDP, verify checksum before handing off to encap_rcv.
> - Remove custom UDP checksum validation code in L2TP.
> 
> Please review carefully and test if possible, mucking with basic
> checksum functions is always a little precarious :-)

This looks good to me, applied, thanks Tom.
