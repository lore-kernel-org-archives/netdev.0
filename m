From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [RFC PATCH 1/4] net: Add support to netdev ops for changing
	hardware queue MAC and VLAN filters
Date: Thu, 19 Nov 2009 14:54:53 +0000
Message-ID: <1258642493.2837.8.camel@achroite.uk.solarflarecom.com>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
	 <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A3162@rrsmsx501.amr.corp.intel.com>
	 <1258586065.2780.31.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A337F@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:58922 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753658AbZKSOyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 09:54:49 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FA69A337F@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-11-18 at 16:33 -0700, Williams, Mitch A wrote:
[...]
> In the case of SR-IOV on our hardware, these filters are perfect - no
> hash tables are required. (We do use hash tables when we have a bunch
> of multicast addresses, but that's not what this is about.)
> 
> MAC filters deny packets by default, so you won't get anything without
> a valid MAC filter on the queue.
> 
> A queue with no VLAN filters will receive packets from all VLANs,
> albeit with the tags passed up intact.  So in that sense, the VLAN
> filters are default-allow.  
> 
> However, once you enable any VLAN filter, the hardware starts
> stripping tags and begins to deny packets by default.
>
> Based on these semantics, the filtering operation that I've described
> above makes perfect sense.
[...]

But they are not the semantics we would want in supposedly generic
netdev operations.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

