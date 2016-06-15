From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vrf: Update flags and features settings
Date: Wed, 15 Jun 2016 14:04:14 -0700 (PDT)
Message-ID: <20160615.140414.1569244843473003397.davem@davemloft.net>
References: <1465863252-17288-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203AbcFOVEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 17:04:15 -0400
In-Reply-To: <1465863252-17288-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 13 Jun 2016 17:14:12 -0700

> 1. Default VRF devices to not having a qdisc (IFF_NO_QUEUE). Users
>    can add one as desired.
> 
> 2. Disable adding a VLAN to a VRF device.
> 
> 3. Enable offloads and hardware features similar to other logical
>    devices (e.g., dummy, veth)
> 
> Change provides a significant boost in TCP stream Tx performance,
> from ~2,700 Mbps to ~18,100 Mbps and makes throughput close to the
> performance without a VRF (18,500 Mbps). netperf TCP_STREAM benchmark
> using qemu with virtio+vhost for the NICs
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
