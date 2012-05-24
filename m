From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v4 PATCH 1/1] netfilter: Add fail-open support
Date: Thu, 24 May 2012 12:41:56 +0200
Message-ID: <20120524104156.GA13785@1984>
References: <20120524082518.13146.25740.sendpatchset@localhost.localdomain>
 <20120524082531.13146.347.sendpatchset@localhost.localdomain>
 <20120524101755.GF13091@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, vivk@us.ibm.com, svajipay@in.ibm.com,
	fw@strlen.de, netfilter-devel@vger.kernel.org, sri@us.ibm.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41265 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932896Ab2EXKmA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 06:42:00 -0400
Content-Disposition: inline
In-Reply-To: <20120524101755.GF13091@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 24, 2012 at 12:17:55PM +0200, Pablo Neira Ayuso wrote:
> My main objection with this patch is that it adds more code out of the
> scope of the nf_queue handling to nf_hook_slow. And this is done for
> very specific purpose.
> 
> @David, @Eric: Krishna aims to provide a mechanism that can be enabled
> to accept packets if the nfqueue becomes full, ie. it changes the
> default behaviour under congestion from drop to accept. It seems some
> users prefer not to block traffic under nfqueue congestion.

Florian Westphal just proposed some possible interesting solution for
this.
