From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: [PATCH 0/2] generalize {DEFINE|REF}_PROTO_INUSE was Re: [PATCH
	0/4] NET : struct proto diet
Date: Wed, 7 Nov 2007 14:16:00 -0200
Message-ID: <20071107161600.GK27345@ghostprotocols.net>
References: <472F5860.4010607@cosmosbay.com> <20071105.234306.200631818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45266 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754041AbXKGQQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 11:16:33 -0500
Content-Disposition: inline
In-Reply-To: <20071105.234306.200631818.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Nov 05, 2007 at 11:43:06PM -0800, David Miller escreveu:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 05 Nov 2007 18:52:32 +0100
> 
> > This patch series does some cleanup and optimization.
> > 
> > [PATCH 1/4] NET : defines an infrastructure to keep 'inuse' changes in 
> > an efficent SMP/NUMA way.
> > [PATCH 2/4] NET : makes ipv4 use the  {DEFINE|REF}_PROTO_INUSE 
> > infrastructure
> > [PATCH 3/4] NET : makes ipv6 use the  {DEFINE|REF}_PROTO_INUSE 
> > infrastructure
> > [PATCH 4/4] NET : makes sctp use the  {DEFINE|REF}_PROTO_INUSE 
> > infrastructure
> 
> Applied, and because I love DCCP I added the following
> patch on top.

Thank you dudes. I found it so nice that I can't help but wonder if this
wouldn't provide for an interesting "class", because this has nothing
that is specific to network protocols, struct proto is just one user...

Lemme try to do this right now:

David,

	Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6

- Arnaldo
