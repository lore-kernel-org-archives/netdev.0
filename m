From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] net: Checksum offload changes - Part IV
Date: Wed, 11 Jun 2014 15:46:35 -0700 (PDT)
Message-ID: <20140611.154635.2203844517927313680.davem@davemloft.net>
References: <alpine.DEB.2.02.1406101848350.5666@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaFKWqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:46:35 -0400
In-Reply-To: <alpine.DEB.2.02.1406101848350.5666@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 10 Jun 2014 18:54:03 -0700 (PDT)

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
> What is in this fourth patch set:
> 
> - Preserve CHECKSUM_COMPLETE instead of changing it to
>   CHECKSUM_UNNECESSARY. This allows correct reuse in validating multiple
>   csums in a packet.
> - When SW needs to compute the packet checksum, save it as
>   CHECKSUM_COMPLETE. Also mark that checksum was compute by SW.
> - Add skb_gro_postpull_rcsum to udp and vxlan to make GRO work with
>   CHECKSUM_COMPLETE.
> 
> v2: Removed patch setting skb_encapsulation when validating checksum
>     in tcp_gro_receive
> 
> Please review carefully and test if possible, mucking with basic
> checksum functions is always a little precarious :-)

Series applied, thanks Tom.
