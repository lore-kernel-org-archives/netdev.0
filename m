From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH] genetlink: export genl_unregister_mc_group()
Date: Thu, 17 Apr 2008 22:52:24 -0700
Message-ID: <200804172252.24829.inaky@linux.intel.com>
References: <200804171254.01950.inaky@linux.intel.com> <20080417.142609.207619557.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, johannes@sipsolutions.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:27273 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753401AbYDRFwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 01:52:30 -0400
In-Reply-To: <20080417.142609.207619557.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 17 April 2008, David Miller wrote:
> > Add an EXPORT_SYMBOL() to genl_unregister_mc_group(), to allow
> > unregistering groups on the run. 
> > ..
> We export functions with in-tree modular users.
> 
> The only reason that genl_register_mc_group() is exported is because
> there are in-tree modular users, ACPI and the NL80211 wireless code.
> 
> Please add this export when code you are writing that needs this
> is merged into the tree.

Sure, 

-- 
Inaky
