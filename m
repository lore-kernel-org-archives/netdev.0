From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 01/18] ipv4: fix path MTU discovery with connection
 tracking
Date: Mon, 20 Aug 2012 09:41:24 +0200
Message-ID: <1345448484.5158.247.camel@edumazet-glaptop>
References: <1345434006-16549-1-git-send-email-kaber@trash.net>
	 <1345434006-16549-2-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345434006-16549-2-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-08-20 at 05:39 +0200, Patrick McHardy wrote:
> IPv4 conntrack defragments incoming packet at the PRE_ROUTING hook and
> (in case of forwarded packets) refragments them at POST_ROUTING
> independant of the IP_DF flag. Refragmentation uses the dst_mtu() of
> the local route without caring about the original fragment sizes,
> thereby breaking PMTUD.
> 
> This patch fixes this by keeping track of the largest received fragment
> with IP_DF set and generates an ICMP fragmentation required error during
> refragmentation if that size exceeds the MTU.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>


