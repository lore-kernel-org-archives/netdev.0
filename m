From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next-2.6] packet: Add GSO/csum offload support.
Date: Fri, 05 Feb 2010 16:27:08 -0800 (PST)
Message-ID: <20100205.162708.238568829.davem@davemloft.net>
References: <1265239340.5600.21.camel@w-sridhar.beaverton.ibm.com>
	<EA929A9653AAE14F841771FB1DE5A1365FDFE68A89@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, herbert@gondor.apana.org.au, mst@redhat.com,
	netdev@vger.kernel.org
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34302
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754332Ab0BFA0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 19:26:54 -0500
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FDFE68A89@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Fri, 5 Feb 2010 17:20:12 -0700

> I am seeing a build failure on one of my systems that has kernel with CONFIG_PACKET_MMAP disabled, which appears to be caused by this patch:
> 
> net/packet/af_packet.c: In function 'packet_setsockopt':
> net/packet/af_packet.c:1977: error: 'struct packet_sock' has no member named 'rx_ring'
> net/packet/af_packet.c:1977: error: 'struct packet_sock' has no member named 'tx_ring'

Thanks for the report.

This is a pretty essential part of AF_PACKET support that
what I'm going to do is simply remove this config option
in net-next-2.6 to fix this problem.

Thanks again.
