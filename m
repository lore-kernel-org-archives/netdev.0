From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 04/15] igb: add locking to reads of the
 i2c interface
Date: Tue, 06 Oct 2009 15:20:58 -0700 (PDT)
Message-ID: <20091006.152058.130185623.davem@davemloft.net>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
	<20091005163226.32487.91764.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47901
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933604AbZJFWVD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:21:03 -0400
In-Reply-To: <20091005163226.32487.91764.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 05 Oct 2009 09:32:27 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The current implementation of sgmii support isn't correctly locking the
> interfaces for reads/writes.  This change pulls the read/write
> functionality out of 82575.c and moves it to phy.c.  In addition it
> replaces the implementation in 82575.c with one that uses locking around
> the relocated i2c interface calls.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
