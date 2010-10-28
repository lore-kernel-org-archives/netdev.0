From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: ethtool: missing implementation of n_priv_flags
Date: Thu, 28 Oct 2010 22:54:18 +0100
Message-ID: <20101028215417.GL15074@solarflare.com>
References: <F169D4F5E1F1974DBFAFABF47F60C10AA5E60671@orsmsx507.amr.corp.intel.com> <20101028210024.GK15074@solarflare.com> <alpine.WNT.2.00.1010281405001.11080@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jgarzik@redhat.com" <jgarzik@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17094 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759859Ab0J1VyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 17:54:21 -0400
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1010281405001.11080@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
[...]
> We'll take a shot at an implementation in the ethtool proper and post it 
> (hopefully soon).  I imagine it will just be printed when one runs the 
> command 
> # ethtool ethX
> 
> and the set side will probably be implemented as part of -s
> 
> # ethtool -s ethX pflag [0-0xFFFFFFFF]

This is crap.  Use ETHTOOL_GSTRINGS with string_set = ETH_SS_PRIV_FLAGS
to get the flag names, then convert that array into an array of struct
cmdline_info and parse the flags by name.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
