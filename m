From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [patch net-next 2/2] netfilter: push reasm skb through instead
 of original frag skbs
Date: Thu, 7 Nov 2013 00:17:48 +0200 (EET)
Message-ID: <alpine.LFD.2.03.1311070010300.1931@ssi.bg>
References: <1383756740-7392-1-git-send-email-jiri@resnulli.us> <1383756740-7392-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, edumazet@google.com, pshelar@nicira.com,
	jasowang@redhat.com, alexander.h.duyck@intel.com, fw@strlen.de
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54055 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756104Ab3KFWU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 17:20:56 -0500
In-Reply-To: <1383756740-7392-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 6 Nov 2013, Jiri Pirko wrote:

...

> As was discussed previously, the only correct solution seems to be to use
> reassembled skb instead of separete frags. Doing this has positive side
> effects in reducing sk_buff by one pointer (nfct_reasm) and also the reams
> dances in ipvs and conntrack can be removed.
> 
> Future plan is to remove net/ipv6/netfilter/nf_conntrack_reasm.c
> entirely and use code in net/ipv6/reassembly.c instead.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

	No obvious problems with the IPVS changes.

Acked-by: Julian Anastasov <ja@ssi.bg>
