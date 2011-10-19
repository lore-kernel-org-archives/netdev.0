From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot
 device
Date: Wed, 19 Oct 2011 17:03:36 -0400 (EDT)
Message-ID: <20111019.170336.2159386260187291370.davem@davemloft.net>
References: <1319055172.7658.33.camel@HP1>
	<20111019.164702.1494656842101009040.davem@davemloft.net>
	<4E9F38D6.6030700@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org, dmitry@broadcom.com,
	eilong@broadcom.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425Ab1JSVDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 17:03:40 -0400
In-Reply-To: <4E9F38D6.6030700@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Wed, 19 Oct 2011 13:53:42 -0700

> As a reference point this works fine in both FCoE and iSCSI stacks
> today. The device is reset or link is lost for whatever reason
> when the link comes back up the stack logs back in, enumerates
> the luns and the scsi stack recovers as expected.
> 
> Firmware should do the equivalent login, lun enumeration, etc as
> needed.

I rest my case :-)
