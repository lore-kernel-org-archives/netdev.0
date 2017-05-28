From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: add support for OVS offload
Date: Sat, 27 May 2017 20:06:56 -0400 (EDT)
Message-ID: <20170527.200656.1963846123525565873.davem@davemloft.net>
References: <20170527155633.GA2358@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, veerasenareddy.burru@cavium.com,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53020 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdE1AG6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 20:06:58 -0400
In-Reply-To: <20170527155633.GA2358@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Sat, 27 May 2017 08:56:33 -0700

> From: VSR Burru <veerasenareddy.burru@cavium.com>
> 
> Add support for OVS offload.  By default PF driver runs in basic NIC mode
> as usual.  To run in OVS mode, use the insmod parameter "fw_type=ovs".
> 
> For OVS mode, create a management interface for communication with NIC
> firmware.  This communication channel uses PF0's I/O rings.
> 
> Bump up driver version to 1.6.0 to match newer firmware.
> 
> Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

How does this work?

What in userspace installs the OVS rules onto the card?

We do not support direct offload of OVS, as an OVS entity, instead we
required all vendors to make their OVS offloads visible as packet
scheduler classifiers and actions.

The same rules apply to liquidio.

If there is some special set of userspace interfaces that are used to
comunicate with these different firmwares in some liquidio specific
way, I am going to be very upset.  That is definitely not allowed.

I'm not applying this patch until the above is resolved and at least
more information is added to this commit log message to explain how
this stuff works.
