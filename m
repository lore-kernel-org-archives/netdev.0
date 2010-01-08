From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/5] e1000e: perform 10/100 adaptive IFS only
 on parts that support it
Date: Fri, 08 Jan 2010 00:39:45 -0800 (PST)
Message-ID: <20100108.003945.28702795.davem@davemloft.net>
References: <20100108023033.31476.4034.stgit@localhost.localdomain>
	<20100108023134.31476.40191.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34891
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752332Ab0AHIjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 03:39:37 -0500
In-Reply-To: <20100108023134.31476.40191.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 07 Jan 2010 18:31:35 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Adaptive IFS which involves writing to the Adaptive IFS Throttle register
> was being done for all devices supported by the driver even though it is
> not supported (i.e. the register doesn't even exist) on some devices.  The
> feature is supported on 8257x/82583 and ICH/PCH based devices, but not
> on ESB2.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
