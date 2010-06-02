From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packet_mmap: expose hw packet timestamps to network
 packet capture utilities
Date: Wed, 02 Jun 2010 05:54:24 -0700 (PDT)
Message-ID: <20100602.055424.93467981.davem@davemloft.net>
References: <09ED21B37E0F694688A2317C4FED9ED3046E444260@azsmsx504.amr.corp.intel.com>
	<09ED21B37E0F694688A2317C4FED9ED3046E53F595@azsmsx504.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tcpdump-workers@lists.tcpdump.org
To: scott.a.mcmillan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44796
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753144Ab0FBMyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 08:54:14 -0400
In-Reply-To: <09ED21B37E0F694688A2317C4FED9ED3046E53F595@azsmsx504.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mcmillan, Scott A" <scott.a.mcmillan@intel.com>
Date: Thu, 27 May 2010 09:58:19 -0700

> Subject: [RFC PATCH] packet_mmap: expose hw packet timestamps to network packet capture utilities
> 
> This patch adds a setting, PACKET_TIMESTAMP, to specify the packet
> timestamp source that is exported to capture utilities like tcpdump
> by packet_mmap.
> 
> PACKET_TIMESTAMP accepts the same integer bit field as
> SO_TIMESTAMPING.  However, only the SOF_TIMESTAMPING_SYS_HARDWARE
> and SOF_TIMESTAMPING_RAW_HARDWARE values are currently recognized by
> PACKET_TIMESTAMP.  SOF_TIMESTAMPING_SYS_HARDWARE takes precedence
> over SOF_TIMESTAMPING_RAW_HARDWARE if both bits are set.
> 
> If PACKET_TIMESTAMP is not set, a software timestamp generated
> inside the networking stack is used (the behavior before this
> setting was added).
> 
> Signed-off-by: Scott McMillan <scott.a.mcmillan@intel.com>

Ok, this looks fine, applied.

Thanks.
