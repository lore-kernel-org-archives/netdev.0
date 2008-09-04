From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/38] Fix ip{,6}_route_me_harder() in netns
Date: Thu, 04 Sep 2008 18:10:36 +0200
Message-ID: <48C0087C.2080708@trash.net>
References: <20080821215825.GE31136@x200.localdomain> <20080821223958.GA31601@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080821223958.GA31601@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

adobriyan@gmail.com wrote:
> ip_route_me_harder() is called on output codepaths:
> 1) IPVS: honestly, not sure, looks like it can be called during forwarding
> 2) IPv4 REJECT: refreshing comment re skb->dst is valid and assigment of
>    skb->dst right before call :^)
> 3) NAT: called in LOCAL_OUT hook
> 4) iptable_mangle: LOCAL_OUT hook
> 5) nf_ip_reroute(): LOCAL_OUT hook (no clue about queueing packets to luserspace)
> 
> ip6_route_me_harder() is also called in output codepaths:
> 1) ip6table_mangle: LOCAL_OUT hook
> 2) nf_ip6_reroute: LOCAL_OUT hook (ditto)

This changelog doesn't give much clue what the patch is doing
or even what the problem is. It also doesn't seem that you're
very convinced of its correctness.

Please resend with a proper changelog. If you have any questions
about the contexts in which this function is called, just ask.
