From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] igb: clear VF_PROMISC bits instead of
 setting all other bits
Date: Wed, 22 Sep 2010 21:20:12 -0700 (PDT)
Message-ID: <20100922.212012.13754111.davem@davemloft.net>
References: <20100923035538.11511.16233.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52569
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750709Ab0IWETx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 00:19:53 -0400
In-Reply-To: <20100923035538.11511.16233.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Sep 2010 20:56:20 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change corrects an issue in which we were setting all flag bits except
> for promisc instead of clearing the promisc bits due to the incorrect use
> of an |= instead of an &=.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
