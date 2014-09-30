From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] bridge: Fix redefined references
Date: Tue, 30 Sep 2014 11:05:08 +0200
Message-ID: <20140930090508.GA12729@salvia>
References: <1412043404-27494-1-git-send-email-therbert@google.com>
 <20140930.010143.591375062294828360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53165 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbaI3JD6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 05:03:58 -0400
Content-Disposition: inline
In-Reply-To: <20140930.010143.591375062294828360.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 01:01:43AM -0400, David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Mon, 29 Sep 2014 19:16:44 -0700
> 
> > Commit 34666d467cbf1e2e3 ("netfilter: bridge: move br_netfilter out of
> > the core") cause compiler errors when CONFIG_BRIDGE_NETFILTER is not
> > defined.
> > 
> > net/bridge/br_nf_core.c:77:1: error: expected identifier or '(' before '{' token
> > net/bridge/br_nf_core.c:88:115: error: redefinition of 'br_nf_core_init'
> > In file included from net/bridge/br_nf_core.c:23:0:
> > net/bridge/br_private.h:762:59: note: previous definition of 'br_nf_core_init' was here
> > net/bridge/br_nf_core.c:93:6: error: redefinition of 'br_nf_core_fini'
> > In file included from net/bridge/br_nf_core.c:23:0:
> > net/bridge/br_private.h:763:60: note: previous definition of 'br_nf_core_fini' was here
> > 
> > Add #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER) around definitions of
> > the redefined functions.
> > 
> > Signed-off-by: Tom Herbert <therbert@google.com>
> 
> Pablo please either ACK this or provide an alternative fix ASAP.
> 
> This bridging build breakage is impacting a lot of people.

Sorry for the trouble this is causing.

I just sent a patch from Florian to resolve the compilataion breakage
when CONFIG_BRIDGE_NETFILTER=n.

Thanks.
