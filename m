From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 06/15] igb: make use of the uta to allow
 for promiscous mode filter
Date: Tue, 06 Oct 2009 15:21:09 -0700 (PDT)
Message-ID: <20091006.152109.161018474.davem@davemloft.net>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
	<20091005163307.32487.75656.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47908
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933763AbZJFWVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:21:14 -0400
In-Reply-To: <20091005163307.32487.75656.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 05 Oct 2009 09:33:08 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> In order to support functions such as vlan tag stripping when SR-IOV is
> enabled any given packet must match at least one filter.  However in the
> case of promiscous mode being enabled on the PF the traffic routed to it
> may not match any filters and is just sent to the PF by default.  In order
> to make certain that this traffic is processed we can set all bits in the
> UTA registers to create a pseudo promiscous mode filter that accepts all
> packets.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
