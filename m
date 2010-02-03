From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 3/5] net: Add netdev ops for SR-IOV
 configuration
Date: Wed, 03 Feb 2010 22:00:09 +0000
Message-ID: <1265234409.2116.63.camel@achroite.uk.solarflarecom.com>
References: <20100130103842.26633.73429.stgit@localhost.localdomain>
	 <20100130104008.26633.93050.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35390 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295Ab0BCWAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 17:00:13 -0500
In-Reply-To: <20100130104008.26633.93050.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-01-30 at 02:40 -0800, Jeff Kirsher wrote:
> From: Williams, Mitch A <mitch.a.williams@intel.com>
> 
> Add netdev ops for configuring SR-IOV VF devices through the PF driver.
[...]

If this is going to be specific to SR-IOV then it doesn't belong in
net_device_ops.

Look again at Dave's comments in
<http://article.gmane.org/gmane.linux.network/147158> and my question in
<http://article.gmane.org/gmane.linux.network/147114>.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

