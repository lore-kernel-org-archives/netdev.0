From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 10/16] Don't lookup the socket if there's a
 socket attached to the skb
Date: Tue, 07 Oct 2008 11:42:15 -0700 (PDT)
Message-ID: <20081007.114215.97715221.davem@davemloft.net>
References: <20081003134747.GH17843@ghostprotocols.net>
	<1223364984.35518.3.camel@nessa.odu>
	<20081007123657.GC29610@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidden@sch.bme.hu, kaber@trash.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56220
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750880AbYJGSmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 14:42:39 -0400
In-Reply-To: <20081007123657.GC29610@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 7 Oct 2008 09:36:57 -0300

> Em Tue, Oct 07, 2008 at 09:36:24AM +0200, KOVACS Krisztian escreveu:
> > inet_hashtables: Add inet_lookup_skb helpers
> > 
> > To be able to use the cached socket reference in the skb during input
> > processing we add a new set of lookup functions that receive the skb on
> > their argument list.
> > 
> > From: Arnaldo Carvalho de Melo <acme@redhat.com>
> > 
> > Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> > Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
> 
> Thanks a lot!

Applied to net-next-2.6
