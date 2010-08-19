From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 16/20] ixgbe: move all GPIE register
 config into a single function
Date: Thu, 19 Aug 2010 16:47:10 -0700 (PDT)
Message-ID: <20100819.164710.232769159.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233917.10335.91882.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753042Ab0HSXqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:46:53 -0400
In-Reply-To: <20100819233917.10335.91882.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:39:20 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change moves all GPIE register configuration into a single function.
> The advantage of this is that we can avoid a number of unnecessary
> read/modify/write cycles on the register.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
