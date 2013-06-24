From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Netfilter/IPVS fixes for net
Date: Mon, 24 Jun 2013 12:47:48 -0700 (PDT)
Message-ID: <20130624.124748.229546123915597217.davem@davemloft.net>
References: <1372086950-4042-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab3FXTrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 15:47:49 -0400
In-Reply-To: <1372086950-4042-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 24 Jun 2013 17:15:44 +0200

> The following patchset contains five fixes for Netfilter/IPVS, they are:
> 
> * A skb leak fix in fragmentation handling in case that helpers are in place,
>   it occurs since the IPV6 NAT infrastructure, from Phil Oester.
> 
> * Fix SCTP port mangling in ICMP packets for IPVS, from Julian Anastasov.
> 
> * Fix event delivery in ctnetlink regarding the new connlabel infrastructure,
>   from Florian Westphal.
> 
> * Fix mangling in the SIP NAT helper, from Balazs Peter Odor.
> 
> * Fix crash in ipt_ULOG introduced while adding netnamespace support,
>   from Gao Feng.
> 
> I'll take care of passing several of these patches to -stable once they hit
> Linus' tree.
> 
> You can pull these changes from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks.
