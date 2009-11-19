From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [RFC PATCH 1/4] net: Add support to netdev ops for changing
	hardware queue MAC and VLAN filters
Date: Thu, 19 Nov 2009 18:59:15 +0000
Message-ID: <1258657155.2837.10.camel@achroite.uk.solarflarecom.com>
References: <20091117214923.15119.98918.stgit@localhost.localdomain>
	 <1258573987.2780.20.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A3162@rrsmsx501.amr.corp.intel.com>
	 <1258586065.2780.31.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA69A337F@rrsmsx501.amr.corp.intel.com>
	 <1258642493.2837.8.camel@achroite.uk.solarflarecom.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FA6A1FF82@rrsmsx501.amr.corp.intel.com>
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
Received: from exchange.solarflare.com ([216.237.3.220]:14923 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079AbZKSS7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 13:59:12 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FA6A1FF82@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-11-19 at 11:43 -0700, Williams, Mitch A wrote:
[...]
> OK, point taken.  Specific hardware features/limitations shouldn't affect kernel policy.
> 
> However, I'm still back to code complexity, and general usage models.
> 
> Please explain specifically what you perceive to be the difference between:
> 
> $ ip link set eth1 queue 1 mac <blah>
> $ ip link set eth1 queue 1 vlan <foo>
> 
> and
> 
> $ ip link set eth1 queue 1 mac <blah> vlan <foo>
> 
> The two filter types are, in my mind, completely orthogonal.  You can
> have one, or the other, or both, or neither. What do we gain by
> glomming both options on one command line?  And is this worth the
> tradeoff of more complex code?

I think you need to state clearly what semantics you are now proposing
before I can make any judgement on them.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

