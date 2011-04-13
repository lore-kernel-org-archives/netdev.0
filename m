From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 RFC PATCH v2 00/13] ethtool: allow custom
 interval for
Date: Wed, 13 Apr 2011 21:11:04 +0100
Message-ID: <1302725464.2873.7.camel@bwh-desktop>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bruce Allan <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:47508 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757443Ab1DMULH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 16:11:07 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-13 at 12:58 -0700, Bruce Allan wrote:
> physical identification
> 
> The following series changes the recently added ethtool set_phys_id
> functions to allow drivers to provide a frequency at which to cycle
> through an on/off identifier via software if/when the capability is
> not provided by hardware.
[...]

The first patch leaves all the drivers broken temporarily.  Since the
change in each driver is trivial, I think you can squash this all into
one patch.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

