From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 13:49:26 -0700
Message-ID: <4856D1D6.7040207@intel.com>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com> <20080616204411.M52834@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	linux.nics@intel.com
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30330 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957AbYFPUvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 16:51:23 -0400
In-Reply-To: <20080616204411.M52834@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> [    5.227679] e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
> [    5.227681] e1000e: Copyright (c) 1999-2008 Intel Corporation.
> [    5.227724] e1000e 0000:00:19.0: enabling device (0000 -> 0003)
> [    5.227731] ACPI: PCI Interrupt 0000:00:19.0[A] -> GSI 20 (level, low) ->
> IRQ 20
> [    5.227742] PCI: Setting latency timer of device 0000:00:19.0 to 64
> [    5.424362] eth1: (PCI Express:2.5GB/s:Width x1) 00:19:d1:71:5f:33
> [    5.424364] eth1: Intel(R) PRO/1000 Network Connection
> [    5.424385] eth1: MAC: 4, PHY: 6, PBA No: ffffff-0ff
> [    5.985995] warning: `zebra' uses 32-bit capabilities (legacy support in use)
> [    6.337111] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)

disable (all of) netfilter if you don't need it. DEFINATELY do disable
nf_conntrack as it's known problematic for routing performance.

Auke

