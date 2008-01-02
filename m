From: David Miller <davem@davemloft.net>
Subject: Re: [NET] Sparse annotations
Date: Tue, 01 Jan 2008 21:58:40 -0800 (PST)
Message-ID: <20080101.215840.130443274.davem@davemloft.net>
References: <477B2616.4090409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47406
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751337AbYABF6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 00:58:40 -0500
In-Reply-To: <477B2616.4090409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 02 Jan 2008 06:50:14 +0100

> Add __acquires() and __releases() annotations to suppress some sparse warnings.
> 
> example of warnings :
> 
> net/ipv4/udp.c:1555:14: warning: context imbalance in 'udp_seq_start' - wrong 
> count at exit
> net/ipv4/udp.c:1571:13: warning: context imbalance in 'udp_seq_stop' - 
> unexpected unlock
> 
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
