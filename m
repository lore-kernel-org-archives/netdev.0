From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] igb: cleanup usage of virtualization
 registers
Date: Mon, 22 Mar 2010 18:30:43 -0700 (PDT)
Message-ID: <20100322.183043.257517432.davem@davemloft.net>
References: <20100323000724.19939.17642.stgit@localhost.localdomain>
	<20100323000744.19939.65933.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59909
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756549Ab0CWBaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 21:30:20 -0400
In-Reply-To: <20100323000744.19939.65933.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 22 Mar 2010 17:07:46 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The igb driver was incorrectly attempting to write to registers that do not
> exist on 82580 hardware.  This wasn't causing any issues that I can tell,
> but it is not recommended behavior either so I have changed this so we are
> determining which registers to write to based on mac type.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
