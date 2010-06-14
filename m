From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000: Fix message logging defect
Date: Sun, 13 Jun 2010 18:21:18 -0700 (PDT)
Message-ID: <20100613.182118.183044035.davem@davemloft.net>
References: <20100611225148.31194.61945.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, joe@perches.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58326
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753351Ab0FNBVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 21:21:07 -0400
In-Reply-To: <20100611225148.31194.61945.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 11 Jun 2010 15:51:49 -0700

> From: Joe Perches <joe@perches.com>
> 
> commit 675ad47375c76a7c3be4ace9554d92cd55518ced
> removed the capability to use ethtool.set_msglevel to
> control the types of messages emitted by the driver.
> 
> That commit should probably be reverted.
> 
> If not, then this patch fixes a message logging defect
> introduced by converting a printk without KERN_<level>
> to e_info.
> 
> This also reduces text by about 200 bytes.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
