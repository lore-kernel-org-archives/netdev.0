From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/14] mlxws: update driver to support offload
 of bridged vlan devices
Date: Tue, 15 Dec 2015 12:01:39 -0500 (EST)
Message-ID: <20151215.120139.382714446824576938.davem@davemloft.net>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932462AbbLORBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 12:01:42 -0500
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 15 Dec 2015 16:03:33 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido Schimmel says:
>         
> ====================
> This patchset introduces support for the offloading of 802.1D bridges
> between VLAN devices. These can either be VLAN devices configured on top
> of the physical ports or on top of LAG devices.
> 
> Patches 1-2 deal with the necessary infrastructure changes needed in order
> to enable the above. The main change is that switchdev drivers can now know
> the device from which the switchdev op originated from.
> 
> Patches 3-10 lay the groundwork for 802.1D bridges support in the mlxsw
> driver, with patch 4 doing most of the heavy lifting.
> 
> Patch 11 finally offloads these bridges to hardware by listening to the
> notifications sent when the VLAN device joins or leaves a bridge. It is
> very similar to the already existing 802.1Q bridge we support.
> 
> Patches 12-14 add minor modifications to allow one to bridge a VLAN device
> configured on top of LAG.
> ====================
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Series applied, thanks guys.
