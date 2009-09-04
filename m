From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] ixgbe: Add support for using FCoE DDP in
 82599 as FCoE targets
Date: Thu, 03 Sep 2009 20:09:22 -0700 (PDT)
Message-ID: <20090903.200922.239125551.davem@davemloft.net>
References: <20090904005549.14869.66878.stgit@localhost.localdomain>
	<20090904005630.14869.67340.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51023
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932798AbZIDDJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:09:07 -0400
In-Reply-To: <20090904005630.14869.67340.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 03 Sep 2009 17:56:31 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> The FCoE DDP in 82599 can be used for both FCoE initiator as well as FCoE
> target, depending on the indication of the exchange being the responder or
> originator in the F_CTL (frame control) field in the encapsulated Fiber
> Channel frame header (T10 Spec., FC-FS). For the initiator, OX_ID is used
> for FCoE DDP, where for the target RX_ID is used for FCoE DDP.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
