From: Hans Schillstrom <hans@schillstrom.com>
Subject: Re: [PATCH] NETFILTER module xt_hmark new target for HASH MARK
Date: Thu, 3 Feb 2011 18:40:36 +0100
Message-ID: <201102031840.37099.hans@schillstrom.com>
References: <1296740050-6311-1-git-send-email-hans.schillstrom@ericsson.com> <4D4AD305.2060505@netfilter.org> <alpine.LNX.2.01.1102031731010.30984@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw11.han.skanova.net ([81.236.55.20]:46902 "EHLO
	smtp-gw11.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756643Ab1BCRkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 12:40:39 -0500
In-Reply-To: <alpine.LNX.2.01.1102031731010.30984@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 

Mvh
Hasse Schillstrom
070-699 7150

On Thursday, February 03, 2011 17:32:07 Jan Engelhardt wrote:
> 
> On Thursday 2011-02-03 17:08, Pablo Neira Ayuso wrote:
> >>> Hm, this is actually not straight forward to implement, you'll have to
> >>> use hook functions to avoid the module dependencies with conntrack and
> >>> that's pretty annoying.
> >>>
> >>> I don't come up with a good solution for this.
> >> 
> >> If it loads conntrack always, there is the option to shovel it
> >> into xt_connmark.c.
> >
> >the problem is that Hans wants this not to depend on conntrack always.
> 
> Well you porbably won't get around the nf_conntrack module dependency,
> but conntrack can still be disabled through CT --notrack
> if one does not like the runtime cost.
> 

If you do put this in front of a bunch of load balancers, 
there is probably a lot of traffic :-)

So that's the reason why I don't want do depend upon conntrack.
