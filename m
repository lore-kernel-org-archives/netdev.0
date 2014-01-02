From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv4: arp: update neighbour address when a
 gratuitous arp is received and arp_accept is set
Date: Wed, 01 Jan 2014 23:38:34 -0500 (EST)
Message-ID: <20140101.233834.1721631702711130638.davem@davemloft.net>
References: <1387923422-4247-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, hannes@stressinduktion.org, netdev@vger.kernel.org
To: noureddine@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774AbaABEig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 23:38:36 -0500
In-Reply-To: <1387923422-4247-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salam Noureddine <noureddine@aristanetworks.com>
Date: Tue, 24 Dec 2013 14:17:02 -0800

> Gratuitous arp packets are useful in switchover scenarios to update
> client arp tables as quickly as possible. Currently, the mac address
> of a neighbour is only updated after a locktime period has elapsed
> since the last update. In most use cases such delays are unacceptable
> for network admins. Moreover, the "updated" field of the neighbour
> stucture doesn't record the last time the address of a neighbour
> changed but records any change that happens to the neighbour. This is
> clearly a bug since locktime uses that field as meaning "addr_updated".
> With this observation, I was able to perpetuate a stale address by
> sending a stream of gratuitous arp packets spaced less than locktime
> apart. With this change the address is updated when a gratuitous arp
> is received and the arp_accept sysctl is set.
> 
> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>

This patch doesn't apply, please regenerate this patch against current
sources.
