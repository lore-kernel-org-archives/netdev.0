From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] xen-netback: fix multiple extra info
 handling
Date: Sun, 13 Mar 2016 22:08:16 -0400 (EDT)
Message-ID: <20160313.220816.289345459908765527.davem@davemloft.net>
References: <1457613028-10381-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932512AbcCNCIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 22:08:19 -0400
In-Reply-To: <1457613028-10381-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Thu, 10 Mar 2016 12:30:25 +0000

> If a frontend passes multiple extra info fragments to netback on the guest
> transmit side, because xen-netback does not account for this properly, only
> a single ack response will be sent. This will eventually cause processing
> of the shared ring to wedge.
> 
> This series re-imports the canonical netif.h from Xen, where the ring
> protocol documentation has been updated, fixes this issue in xen-netback
> and also adds a patch to reduce log spam.

Series applied, thanks Paul.
