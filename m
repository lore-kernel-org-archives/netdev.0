From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] pktgen: fix UDP checksum computation
Date: Thu, 5 Feb 2015 10:52:16 +0000
Message-ID: <20150205105216.GB24388@casper.infradead.org>
References: <1423087730-9201-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54877 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756928AbbBEKwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 05:52:19 -0500
Content-Disposition: inline
In-Reply-To: <1423087730-9201-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/15 at 11:08pm, Sabrina Dubroca wrote:
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

Acked-by: Thomas Graf <tgraf@suug.ch>

Thanks for fixing this.
