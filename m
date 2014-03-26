From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [RFC v2 1/1] net: Add support to configure SR-IOV VF minimum and maximum Tx rate through ip tool.
Date: Wed, 26 Mar 2014 08:37:03 +0100
Message-ID: <2029402.2DirnyqmAY@alaris>
References: <1395637073-29794-1-git-send-email-sucheta.chakraborty@qlogic.com> <1395637073-29794-2-git-send-email-sucheta.chakraborty@qlogic.com> <1395687300.2832.37.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com,
	gregory.v.rose@intel.com, linux-net-drivers@solarflare.com,
	Ariel.Elior@qlogic.com, amirv@mellanox.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37205 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793AbaCZHhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 03:37:06 -0400
In-Reply-To: <1395687300.2832.37.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 24 of March 2014 18:55:00 Ben Hutchings wrote:
> 
> Also, this special-casing of -1 isn't documented anywhere.  Is it even
> necessary?  If userland needs to set just one limit, it can read the
> existing limits and set both.

Wouldn't this open a window for a race if one process wanted to change 
one limit and another process wanted to change the other at the same 
time? Such scenario doesn't sound very realistic but our customers 
taught me that things I don't find very realistic tend to be used quite 
frequently by them.

On the other hand, if changing only one limit is going to be common, it 
might be more appropriate to add IFLA_VF_TX_MIN_RATE instead and always 
pass the minimum and maximum rate separately (and pass only one if only 
one is going to be changed).

                                                         Michal Kubecek
