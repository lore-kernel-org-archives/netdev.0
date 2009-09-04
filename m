From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/3] igb: only disable/enable interrupt bits
 for igb physical function
Date: Thu, 03 Sep 2009 20:07:38 -0700 (PDT)
Message-ID: <20090903.200738.102526766.davem@davemloft.net>
References: <20090904004828.14537.72187.stgit@localhost.localdomain>
	<20090904004914.14537.67180.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51006
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932831AbZIDDHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:07:23 -0400
In-Reply-To: <20090904004914.14537.67180.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 03 Sep 2009 17:49:15 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The igb_irq_disable/enable calls were causing virtual functions associated
> with the igb physical function to have their interrupts disabled.  In order
> to prevent this from occuring we should only clear/set the bits related to
> the physical function.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
