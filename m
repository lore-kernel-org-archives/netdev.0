From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 5/6] e1000e: 82579 jumbo frame workaround
 causing CRC errors
Date: Wed, 22 Sep 2010 21:11:10 -0700 (PDT)
Message-ID: <20100922.211110.241458146.davem@davemloft.net>
References: <20100923031432.10976.81909.stgit@localhost.localdomain>
	<20100923031639.10976.20852.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53064
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751013Ab0IWEKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 00:10:50 -0400
In-Reply-To: <20100923031639.10976.20852.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Sep 2010 20:16:40 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The subject workaround was causing CRC errors due to writing the wrong
> register with updates of the RCTL register.  It was also found that the
> workaround function which modifies the RCTL register was being called in
> the middle of a read-modify-write operation of the RCTL register, so the
> function call has been moved appropriately.  Lastly, jumbo frames must not
> be allowed when CRC stripping is disabled by a module parameter because the
> workaround requires the CRC be stripped.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
