From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] ixgbevf: Cache PF ack bit in interrupt
Date: Thu, 06 May 2010 00:32:20 -0700 (PDT)
Message-ID: <20100506.003220.42791584.davem@davemloft.net>
References: <20100506055703.8482.16515.stgit@localhost.localdomain>
	<20100506055748.8482.25239.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57730
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754604Ab0EFHcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:32:13 -0400
In-Reply-To: <20100506055748.8482.25239.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 05 May 2010 22:57:49 -0700

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> When the PF acks a message from the VF the VF gets an interrupt.  It
> must cache the ack bit so that polling SW will not miss the ack.  Also
> avoid reading the message buffer on acks because that also will clear
> the ack bit.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
