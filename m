From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/6] e1000e: 82566DC fails to get link
Date: Wed, 22 Sep 2010 21:10:58 -0700 (PDT)
Message-ID: <20100922.211058.241919360.davem@davemloft.net>
References: <20100923031432.10976.81909.stgit@localhost.localdomain>
	<20100923031553.10976.18727.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	stable@kernel.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751013Ab0IWEKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 00:10:39 -0400
In-Reply-To: <20100923031553.10976.18727.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Sep 2010 20:15:54 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Two recent patches to cleanup the reset[1] and initial PHY configuration[2]
> code paths for ICH/PCH devices inadvertently left out a 10msec delay and
> device ID check respectively which are necessary for the 82566DC (device id
> 0x104b) to be configured properly, otherwise it will not get link.
> 
> [1] commit e98cac447cc1cc418dff1d610a5c79c4f2bdec7f
> [2] commit 3f0c16e84438d657d29446f85fe375794a93f159
> 
> CC: stable@kernel.org
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
