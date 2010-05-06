From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] e1000e: reset MAC-PHY interconnect on
 82577/82578 during Sx->S0
Date: Thu, 06 May 2010 01:22:55 -0700 (PDT)
Message-ID: <20100506.012255.108783613.davem@davemloft.net>
References: <20100506075959.8910.13493.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751363Ab0EFIWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 04:22:48 -0400
In-Reply-To: <20100506075959.8910.13493.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 06 May 2010 01:00:06 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> During Sx->S0 transitions, the interconnect between the MAC and PHY on
> 82577/82578 can remain in SMBus mode instead of transitioning to the
> PCIe-like mode required during normal operation.  Toggling the LANPHYPC
> Value bit essentially resets the interconnect forcing it to the correct
> mode.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
