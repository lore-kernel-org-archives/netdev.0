From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix HAVE_EFFICIENT_UNALIGNED_ACCESS typos
Date: Wed, 20 Apr 2016 11:03:09 -0400 (EDT)
Message-ID: <20160420.110309.205751121546321705.davem@davemloft.net>
References: <57174F8E.6050201@6wind.com>
	<1461146278.10638.253.camel@edumazet-glaptop3.roam.corp.google.com>
	<1461162691.10638.260.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43805 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbcDTPDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 11:03:11 -0400
In-Reply-To: <1461162691.10638.260.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Apr 2016 07:31:31 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> HAVE_EFFICIENT_UNALIGNED_ACCESS needs CONFIG_ prefix.
> 
> Also add a comment in nla_align_64bit() explaining we have
> to add a padding if current skb->data is aligned, as it
> certainly can be confusing.
> 
> Fixes: 35c5845957c7 ("net: Add helpers for 64-bit aligning netlink attributes.")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
