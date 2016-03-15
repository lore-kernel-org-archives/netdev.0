From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] net: ena: Add a driver for Amazon Elastic Network
 Adapters (ENA)
Date: Tue, 15 Mar 2016 13:19:07 -0500
Message-ID: <1458065947.31283.26.camel@redhat.com>
References: <1458039006-19956-1-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	antoine.tenart@free-electrons.com
To: Netanel Belgazal <netanel@annapurnalabs.com>,
	zorik@annapurnalabs.com, saeed@annapurnalabs.com,
	alex@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965146AbcCOSTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2016 14:19:11 -0400
In-Reply-To: <1458039006-19956-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-15 at 12:50 +0200, Netanel Belgazal wrote:
> This is a driver for the Amazon ethernet ENA family.
> The driver operates variety of ENA adapters through
> feature negotiation with the adapter and upgradable commands set.
> ENA driver handles PCI Physical and Virtual ENA functions.
> 
> The ENA device is not yet released to public.
> He is expected to be released soon.
> For the full specification of the device please refer to:
> <SPEC-PATH>
> 
> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> 

<snip>

> diff --git a/Documentation/networking/ena.txt
> b/Documentation/networking/ena.txt
> new file mode 100644
> index 0000000..f10e6db
> --- /dev/null
> +++ b/Documentation/networking/ena.txt
> @@ -0,0 +1,330 @@
> +Linux kernel driver for Elastic Network Adapter (ENA) family:
> +=============================================================
> +
> +Overview:
> +=========
> +The ENA driver provides a modern Ethernet device interface optimized
> +for high performance and low CPU overhead.
> +
> +The ENA driver exposes a lightweight management interface with a
> +minimal set of memory mapped registers and extendable command set
> +through an Admin Queue.
> +
> +The driver supports a wide range of ENA devices, is link-speed
> +independent (i.e., the same driver is used for 10GbE, 25GbE, 40GbE,
> +etc.), and it has a negotiated and extendable feature set.
> +
> +Some ENA devices support SR-IOV. This driver is used for both the
> +SR-IOV Physical Function (PF) and Virtual Function (VF) devices.
> +
> +ENA devices allow high speed and low overhead Ethernet traffic
> +processing by providing a dedicated Tx/Rx queue pair per host CPU, a
> +dedicated MSI-X interrupt vector per Tx/Rx queue pair, adaptive
> +interrupt moderation, and CPU cacheline optimized data placement.
> +
> +The ENA driver supports industry standard TCP/IP offload features
> such
> +as checksum offload and TCP transmit segmentation offload (TSO).
> +
> +Receive-side scaling (RSS) is supported for multi-core scaling.

Any chance it also supports VXLAN offload?

Dan
