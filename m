From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 07/12] e1000e: Cleanup
 e1000_sw_lcd_config_ich8lan()
Date: Wed, 12 May 2010 23:32:16 -0700 (PDT)
Message-ID: <20100512.233216.48497407.davem@davemloft.net>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
	<20100511010108.30827.47964.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45035
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753996Ab0EMGcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:32:08 -0400
In-Reply-To: <20100511010108.30827.47964.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 10 May 2010 18:01:10 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> After every reset all ICH/PCH parts call this function which acquires the
> swflag, performs a workaround on applicable parts and releases the swflag.
> There is no reason for parts for which this workaround is not applicable
> to acquire and release the swflag so the function should just return
> without doing anything for these parts.  This also provides for the
> indentation of most of the function contents to be shifted left cleaning up
> the code.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
