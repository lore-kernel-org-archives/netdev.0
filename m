From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ethtool: missing implementation of n_priv_flags
Date: Thu, 28 Oct 2010 22:00:25 +0100
Message-ID: <20101028210024.GK15074@solarflare.com>
References: <F169D4F5E1F1974DBFAFABF47F60C10AA5E60671@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jgarzik@redhat.com" <jgarzik@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12594 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933674Ab0J1VA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 17:00:28 -0400
Content-Disposition: inline
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10AA5E60671@orsmsx507.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> Was just looking at implementing the driver private flags to add a new feature to 
> a driver.
> 
> It appears that nothing in the core ethtool.c ever accesses or prints n_priv_flags, 
> even if a driver assigns it (which none in the kernel currently do)
[...]

You mean net/core/ethtool.c?  Or the ethtool utility?

If you set it in your get_drvinfo() operation then it will be copied out.
As for the ethtool utility, I've implemented some generic flag parsing and
printing functionality so it shouldn't be too hard to use that for private
flags.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
