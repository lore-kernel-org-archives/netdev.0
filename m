From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v4 net-next] udp: Increment UDP_MIB_IGNOREDMULTI for
 arriving unmatched multicasts
Date: Fri, 07 Nov 2014 15:46:47 -0500 (EST)
Message-ID: <20141107.154647.1153472232949337302.davem@redhat.com>
References: <20141106183754.8A52829007D9@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raj@tardy.usa.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59083 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285AbaKGUr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 15:47:56 -0500
In-Reply-To: <20141106183754.8A52829007D9@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.usa.hp.com (Rick Jones)
Date: Thu,  6 Nov 2014 10:37:54 -0800 (PST)

> From: Rick Jones <rick.jones2@hp.com>
> 
> As NIC multicast filtering isn't perfect, and some platforms are
> quite content to spew broadcasts, we should not trigger an event
> for skb:kfree_skb when we do not have a match for such an incoming
> datagram.  We do though want to avoid sweeping the matter under the
> rug entirely, so increment a suitable statistic.
> 
> This incorporates feedback from David L. Stevens, Karl Neiss and Eric
> Dumazet.
> 
> V3 - use bool per David Miller
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied, thanks Rick.
