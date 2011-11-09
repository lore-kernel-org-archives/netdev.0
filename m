From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v2 PATCH 1/2] NETFILTER module xt_hmark new target for HASH
 based fw
Date: Wed, 9 Nov 2011 15:39:22 +0100
Message-ID: <20111109143922.GC24174@1984>
References: <b328f1j.5274a2398142147da04eb5e915d63283@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, kaber@trash.net,
	jengelh@medozas.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51579 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746Ab1KIOjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 09:39:25 -0500
Content-Disposition: inline
In-Reply-To: <b328f1j.5274a2398142147da04eb5e915d63283@obelix.schillstrom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 08, 2011 at 04:12:27PM +0100, Hans Schillstrom wrote:
> >BTW, do you have some number of this running with and without
> >conntrack? It would be interesting to have.
> 
> I didn't save them,  but I can make a new benchmark later on.

Thanks, I'm interested in them. It can be just xt_HMARK with and
without conntrack enabled. Also make sure that you use stateful
rule-set if conntrack is enabled (thus, resulting in hashing only
once, not every packet). Otherwise, conntrack will not provide
any improvement.
