From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 17/20] ixgbe: pull all Tx init into
 ixgbe_configure_tx
Date: Thu, 19 Aug 2010 16:47:15 -0700 (PDT)
Message-ID: <20100819.164715.229726495.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233940.10335.28076.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60461
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753042Ab0HSXq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:46:59 -0400
In-Reply-To: <20100819233940.10335.28076.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:39:43 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The Tx init was spread out over ixgbe_configure, ixgbe_configure_tx, and
> ixgbe_up_complete.  This change combines all of that into the
> ixgbe_configure_tx function in order to simplify the Tx init path.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
