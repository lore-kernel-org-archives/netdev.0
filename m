From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH resend nf-next] netfilter: xt_CT: optimize XT_CT_NOTRACK
Date: Thu, 23 May 2013 12:54:04 +0200
Message-ID: <20130523105404.GB22507@localhost>
References: <1368132751.13473.113.camel@edumazet-glaptop>
 <1369257057.3301.367.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47569 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757558Ab3EWKyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 06:54:15 -0400
Content-Disposition: inline
In-Reply-To: <1369257057.3301.367.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 02:10:57PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> The percpu untracked ct are not currently used for XT_CT_NOTRACK.
> 
> xt_ct_tg_check()/xt_ct_target() provides a single ct.
> 
> Thats not optimal as the ct->ct_general.use cache line will bounce among
> cpus.
> 
> Use the intended [1] thing : xt_ct_target() should select the percpu
> object.
> 
> [1] Refs :
> commit 5bfddbd46a95c97 ("netfilter: nf_conntrack: IPS_UNTRACKED bit")
> commit b3c5163fe0193a7 ("netfilter: nf_conntrack: per_cpu untracking")

Applied, thanks Eric.
