From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/17] mlxsw: Introduce support for Data
 Center Bridging
Date: Wed, 06 Apr 2016 17:24:38 -0400 (EDT)
Message-ID: <20160406.172438.2294254065768146784.davem@davemloft.net>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521AbcDFVYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 17:24:41 -0400
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  6 Apr 2016 17:09:59 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> This patchset introduces support for Quality of Service (QoS) as part of the
> IEEE Data Center Bridiging (DCB) standards.
> 
> Patches 1-9 do the required device initialization. Specifically, patches 1-6
> initialize the ports' headroom buffers, which are used at ingress to store
> incoming packets while they go through the switch's pipeline. Patches 7-9
> complete them by initializing the egress scheduling.
> 
> The pipeline mentioned above determines the packet's egress port(s) and
> traffic class. Ideally, once out of the pipeline the packet moves to the
> switch's shared buffer (to be introduced in Jiri's patchset, currently
> default values are used) and scheduled for transmission according to its
> traffic class. The egress scheduling is configured according to the 802.1Qaz
> standard, which is part of the DCB infrastructure supported by Linux. This
> is introduced in patches 10-12.
> 
> Even after going through the pipeline packets are not always eligible to
> enter the shared buffer. This is determined by the amount of available space
> and the quotas associated with the packet. However, if flow control is
> enabled and the packet is associated with the lossless flow, then it will
> stay in the headroom and won't be discarded. This is introduced in patches
> 13-17.
> 
> Please check individual commit messages for more info, as I tried to keep
> them pretty detailed.

Series applied, thanks guys.
