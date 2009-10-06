From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 13/15] igb: add code to retry a phy read
 in the event of failure on link check
Date: Tue, 06 Oct 2009 15:21:54 -0700 (PDT)
Message-ID: <20091006.152154.14398379.davem@davemloft.net>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
	<20091005163522.32487.5411.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47936
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933823AbZJFWV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:21:59 -0400
In-Reply-To: <20091005163522.32487.5411.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 05 Oct 2009 09:35:23 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch adds a retry to phy reads in the event of failure.  The original
> code broke out of the loop on failure and this is a mistake as we should be
> trying to do the read twice.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
