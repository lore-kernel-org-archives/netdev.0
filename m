From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 23:16:47 -0700 (PDT)
Message-ID: <20060426.231647.64561336.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143AE6C@NT-SJCA-0751.brcm.ad.broadcom.com>
	<1146109226.11864.37.camel@localhost.localdomain>
	<Pine.LNX.4.64.0604270055010.6286@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, caitlinb@broadcom.com, kelly@au1.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27875
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964954AbWD0GRF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Apr 2006 02:17:05 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0604270055010.6286@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Thu, 27 Apr 2006 00:58:41 -0400 (EDT)

> On Thu, 27 Apr 2006, Rusty Russell wrote:
> 
> > netfilter (similarly raw sockets, bonding, divert).  Or, we could delay
> > LOCAL_IN hook processing until we get to socket receive.
> 
> This an idea proposed for skfilter [1], too, allowing packets to be 
> filtered by local endpoint.
> 
> [1] http://people.redhat.com/jmorris/selinux/skfilter/

Moving forward this really is an important problem that we'll need to
solve, and we'll need to solve it such that netfilter can be fully
enabled in tandem with net channels doing their thing.

It's simple, if we don't make them work together, then as a
consequence the real life sites that would benefit the most from net
channels will not see the benefit from them because they will use
netfilter and they will have firewall rules enabled.  Our work is
largely wasteful if that's what happens.

But let's move forward on the bits we can implement now, believing
optimistically that we will find a way to deal with this issue
properly. :-)


