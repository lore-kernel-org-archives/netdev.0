From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/6] net: Checksum offload changes - Part V
Date: Sun, 24 Aug 2014 18:24:50 -0700 (PDT)
Message-ID: <20140824.182450.1565360550397265947.davem@davemloft.net>
References: <alpine.DEB.2.02.1408221315240.1209@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752917AbaHYBYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 21:24:53 -0400
In-Reply-To: <alpine.DEB.2.02.1408221315240.1209@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 22 Aug 2014 13:33:38 -0700 (PDT)

> I am working on overhauling RX checksum offload. Goals of this effort
> are:
> 
> - Specify what exactly it means when driver returns CHECKSUM_UNNECESSARY
> - Preserve CHECKSUM_COMPLETE through encapsulation layers
> - Don't do skb_checksum more than once per packet
> - Unify GRO and non-GRO csum verification as much as possible
> - Unify the checksum functions (checksum_init)
> - Simplify code
> 
> What is in this fifth patch set:
> 
> - Added GRO checksum validation functions
> - Call the GRO validations functions from TCP and GRE gro_receive
> - Perform checksum verification in the UDP gro_receive path using
>   GRO functions and add support for gro_receive in UDP6
> 
> Changes in V2:
> 
> - Change ip_summed to CHECKSUM_UNNECESSARY instead of moving it
>   to CHECKSUM_COMPLETE from GRO checksum validation. This avoids
>   performance penalty in checksumming bytes which are before the header
>   GRO is at.
> 
> Please review carefully and test if possible, mucking with basic
> checksum functions is always a little precarious :-)

Looks good, applied, thanks Tom.
