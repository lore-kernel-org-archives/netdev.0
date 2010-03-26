From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] ixgbevf: Fix signed/unsigned int error
Date: Fri, 26 Mar 2010 11:56:25 -0700 (PDT)
Message-ID: <20100326.115625.178766195.davem@davemloft.net>
References: <20100324193515.6078.27035.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50451
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752179Ab0CZS4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 14:56:01 -0400
In-Reply-To: <20100324193515.6078.27035.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Mar 2010 12:35:42 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> In the Tx mapping function if a DMA error occurred then the unwind of
> previously mapped sections would improperly check an unsigned int if
> it was less than zero.  Changed the index variable to signed to avoid
> the error.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
