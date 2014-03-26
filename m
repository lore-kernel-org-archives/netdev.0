From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Do not include vlan acceleration features in
 vlan_features
Date: Wed, 26 Mar 2014 15:56:14 -0400 (EDT)
Message-ID: <20140326.155614.1586642968372896396.davem@davemloft.net>
References: <1395697932-28247-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com, mchan@broadcom.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902AbaCZT4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:56:16 -0400
In-Reply-To: <1395697932-28247-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Mon, 24 Mar 2014 17:52:12 -0400

> Including hardware acceleration features in vlan_features breaks
> stacked vlans (Q-in-Q) by marking the bottom vlan interface as
> capable of acceleration.  This causes one of the tags to be lost
> and the packets are sent with a sing vlan header.
> 
> CC: Nithin Nayak Sujir <nsujir@broadcom.com>
> CC: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Applied and queued up for -stable, thanks.

This is at least the second time I've seen a fix exactly like this
one, it certainly therefore deserves a tree-wide audit if anyone has
time for that.
