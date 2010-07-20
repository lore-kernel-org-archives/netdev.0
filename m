From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000: allow option to limit number of
 descriptors down to 48 per ring
Date: Mon, 19 Jul 2010 20:24:01 -0700 (PDT)
Message-ID: <20100719.202401.129745775.davem@davemloft.net>
References: <20100719234219.13875.90302.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37845
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758143Ab0GTDXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 23:23:48 -0400
In-Reply-To: <20100719234219.13875.90302.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 19 Jul 2010 16:43:47 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change makes it possible to limit the number of descriptors down to 48
> per ring.  The reason for this change is to address a variation on hardware
> errata 10 for 82546GB in which descriptors will be lost if more than 32
> descriptors are fetched and the PCI-X MRBC is 512.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
