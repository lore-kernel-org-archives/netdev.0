From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next fragmentation icmp v5 3/3] bridge_netfilter: No ICMP
 packet on IPv4 fragmentation error
Date: Sat, 16 May 2015 00:31:56 +0200
Message-ID: <20150515223156.GM6179@breakpoint.cc>
References: <1431724537-1919-1-git-send-email-azhou@nicira.com>
 <1431724537-1919-4-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49645 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932217AbbEOWb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 18:31:59 -0400
Content-Disposition: inline
In-Reply-To: <1431724537-1919-4-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Zhou <azhou@nicira.com> wrote:
> When bridge netfilter re-fragments an IP packet for output, all
> packets that can not be re-fragmented to their original input size
> should be silently discarded.
> 
> However, current bridge netfilter output path generates an ICMP packet
> with 'size exceeded MTU' message for such packets, this is a bug.
> 
> This patch refactors the ip_fragment() API to allow two separate
> use cases. The bridge netfilter user case will not
> send ICMP, the routing output will, as before.
> 
> Signed-off-by: Andy Zhou <azhou@nicira.com>

for bridge netfilter:
Acked-by: Florian Westphal <fw@strlen.de>
