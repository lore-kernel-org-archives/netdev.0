From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] Checksum fixes
Date: Sun, 15 Jun 2014 01:01:13 -0700 (PDT)
Message-ID: <20140615.010113.950904601534084657.davem@davemloft.net>
References: <alpine.DEB.2.02.1406142312290.17261@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joseph.gasparakis@intel.com,
	geert@linux-m68k.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaFOIBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 04:01:17 -0400
In-Reply-To: <alpine.DEB.2.02.1406142312290.17261@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sat, 14 Jun 2014 23:23:44 -0700 (PDT)

> Fixes related to some recent checksum modifications.
> 
> - Fix GSO constants to match NETIF flags
> - Fix logic in saving checksum complete in __skb_checksum_complete
> - Call __skb_checksum_complete from UDP if we are checksumming over
>   whole packet in order to save checksum.
> - Fixes to VXLAN to work correctly with checksum complete

Series applied, thanks Tom.
