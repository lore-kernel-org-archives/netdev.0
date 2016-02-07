From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/2] virtio_net: add ethtool get/set
 settings support
Date: Sun, 07 Feb 2016 14:31:17 -0500 (EST)
Message-ID: <20160207.143117.2074335859138369633.davem@davemloft.net>
References: <1454468677-12280-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35796 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbcBGTbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:31:22 -0500
In-Reply-To: <1454468677-12280-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Wed,  3 Feb 2016 04:04:35 +0100

> Patch 1 adds ethtool speed/duplex validation functions which check if the
> value is defined. Patch 2 adds support for ethtool (get|set)_settings and
> uses the validation functions to check the user-supplied values.
> 
> v2: split in 2 patches to allow everyone to make use of the validation
> functions and allow virtio_net devices to be half duplex
> v3: added a check to return error if the user tries to change anything else
> besides duplex/speed as per Michael's comment
> v4: Set port type to PORT_OTHER
> v5: clear diff1.port (ignore port) when checking for changes since we set
> it now and ethtool uses it in the set request
> 
> Sorry about the pointless iterations, should've all covered now.

Series applied, thanks Nik.
