From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] netfilter: netfilter fixes
Date: Thu, 20 May 2010 23:12:30 -0700 (PDT)
Message-ID: <20100520.231230.247122843.davem@davemloft.net>
References: <1274371246-26760-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45768
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933062Ab0EUGMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 02:12:21 -0400
In-Reply-To: <1274371246-26760-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Thu, 20 May 2010 18:00:43 +0200

> following are three fixes for netfilter:
> 
> - handling of non-linear skbs in the SIP conntrack helper. This fixes tracking
>   failures when running on the same machine as a SIP application that is
>   producing non-linear skbs. Long term this should be fixed by using the string
>   search API, but that is a bigger piece of work.
> 
> - fix for a race condition in nf_conntrack that might lead to conntrack entries
>   marked as dead entering the hash tables, blocking new connections with similar
>   keys.
> 
> - a fix for an incorrect comment about the checkentry return conventions.
> 
> Please apply or pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Pulled, thanks Patrick.
