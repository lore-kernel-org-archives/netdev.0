From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: always use adapter->itr as EITR value
Date: Mon, 27 Apr 2009 03:16:01 -0700 (PDT)
Message-ID: <20090427.031601.232191146.davem@davemloft.net>
References: <20090423212029.29591.16562.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39872
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753023AbZD0KQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 06:16:10 -0400
In-Reply-To: <20090423212029.29591.16562.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 23 Apr 2009 14:20:29 -0700

> The igb driver was switching between adapter->itr containing the EITR value
> and the number of interrupts per second.  This resulted in high latencies
> being seen after brining the interface down and then back up.  To resolve
> the issue the itr value will now only contain the value that should be
> programmed into EITR.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
