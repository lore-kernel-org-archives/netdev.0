From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] pktgen: fix UDP checksum computation
Date: Thu, 05 Feb 2015 15:42:10 -0800 (PST)
Message-ID: <20150205.154210.440621170776055430.davem@davemloft.net>
References: <1423087730-9201-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbbBEXmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 18:42:11 -0500
In-Reply-To: <1423087730-9201-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Wed,  4 Feb 2015 23:08:50 +0100

> This patch fixes two issues in UDP checksum computation in pktgen.
> 
> First, the pseudo-header uses the source and destination IP
> addresses. Currently, the ports are used for IPv4.
> 
> Second, the UDP checksum covers both header and data.  So we need to
> generate the data earlier (move pktgen_finalize_skb up), and compute
> the checksum for UDP header + data.
> 
> Fixes: c26bf4a51308c ("pktgen: Add UDPCSUM flag to support UDP checksums")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.
