From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: update hw_debug macro to make use of netdev_dbg
 call
Date: Tue, 30 Mar 2010 23:01:23 -0700 (PDT)
Message-ID: <20100330.230123.266658399.davem@davemloft.net>
References: <20100325231007.8991.24570.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756637Ab0CaGBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 02:01:22 -0400
In-Reply-To: <20100325231007.8991.24570.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 25 Mar 2010 16:10:08 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change updates the igb driver to make use of the netdev_dbg function
> macros now provided in netdevice.h
> 
> This is meant to be provided as an alternative to the patch provided by
> Joe Perches.
> 
> It also removes igb_get_time_str since I found that it is unused code that
> is no longer used even in debug.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

I'll apply this to net-next-2.6, thanks.
