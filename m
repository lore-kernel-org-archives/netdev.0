From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCHv2 net 1/3] openvswitch: Fix double-free on ip_defrag()
 errors
Date: Sat, 24 Oct 2015 10:20:25 +0200
Message-ID: <20151024082025.GB19055@breakpoint.cc>
References: <1445643135-65034-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47028 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750846AbbJXIU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 04:20:29 -0400
Content-Disposition: inline
In-Reply-To: <1445643135-65034-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Stringer <joestringer@nicira.com> wrote:
>  err:
> +	if (err)
> +		kfree_skb(skb);
>  	skb_push(skb, nh_ofs);

That looks... wrong :-}
