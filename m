From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH] bonding: fix enslaving in alb mode when link down
Date: Wed, 18 Jan 2012 23:30:41 +0100
Message-ID: <20120118223041.GB11966@midget.suse.cz>
References: <20120118222454.GA11966@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, jbohac@suse.cz
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55296 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754885Ab2ARWam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jan 2012 17:30:42 -0500
Content-Disposition: inline
In-Reply-To: <20120118222454.GA11966@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2012 at 11:24:54PM +0100, Jiri Bohac wrote:
> bond_alb_init_slave() is called from bond_enslave() and sets the slave's MAC
> address. This is done differently for TLB and ALB modes.
> bond->alb_info.rlb_enabled is used to discriminate between the two modes but
> this flag may be uninitialized if the slave is being enslaved prior to calling
> bond_open() -> bond_alb_initialize() on the master.

copying Narendra, who already reported this problem in 
http://lists.openwall.net/netdev/2011/12/27/14
and who has done most of the debugging so far.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
