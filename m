From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 03/15] igb: update the approach taken to
 acquiring and releasing the phy lock
Date: Tue, 06 Oct 2009 15:20:53 -0700 (PDT)
Message-ID: <20091006.152053.184470362.davem@davemloft.net>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
	<20091005163206.32487.22702.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47897
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933770AbZJFWU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:20:58 -0400
In-Reply-To: <20091005163206.32487.22702.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 05 Oct 2009 09:32:07 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The current approach is just using a ?: type mechanism to set the phy
> locking bit.  This if fine for now but limits us to only 2.  Switch to a
> nested if statement for future compatiblity with more than 2 phys.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
