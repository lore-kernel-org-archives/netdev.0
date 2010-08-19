From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 01/20] ixgbe: cleanup ixgbe_get_drvinfo to
 be extra careful with buffer boundaries
Date: Thu, 19 Aug 2010 16:45:53 -0700 (PDT)
Message-ID: <20100819.164553.104043571.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60402
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751947Ab0HSXph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:45:37 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:33:16 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> Make the code in ixgbe_get_drvinfo more protected against buffer overflow
> boundaries by using snprintf and sizeof with snprintf.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
