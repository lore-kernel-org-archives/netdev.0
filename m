From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: export genl_unregister_mc_group()
Date: Thu, 17 Apr 2008 14:26:09 -0700 (PDT)
Message-ID: <20080417.142609.207619557.davem@davemloft.net>
References: <200804171254.01950.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, johannes@sipsolutions.net, netdev@vger.kernel.org
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50127
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755870AbYDQV0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 17:26:07 -0400
In-Reply-To: <200804171254.01950.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Thu, 17 Apr 2008 12:54:01 -0700

> Add an EXPORT_SYMBOL() to genl_unregister_mc_group(), to allow
> unregistering groups on the run. 
> 
> Cleanup is currently done when unregistering a family, but there is
> no way to unregister a single multicast group due to that function not
> being exported. Seems to be a mistake as it is documented as for
> external consumption.
> 
> Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>

We export functions with in-tree modular users.

The only reason that genl_register_mc_group() is exported is because
there are in-tree modular users, ACPI and the NL80211 wireless code.

Please add this export when code you are writing that needs this
is merged into the tree.

Thank you.
