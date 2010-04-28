From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000: Use netdev_<level>, pr_<level> and
 dev_<level>
Date: Tue, 27 Apr 2010 17:05:25 -0700 (PDT)
Message-ID: <20100427.170525.255384756.davem@davemloft.net>
References: <20100428000252.27254.91773.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, joe@perches.com,
	emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50460
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755532Ab0D1AFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 20:05:20 -0400
In-Reply-To: <20100428000252.27254.91773.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 17:02:58 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> This patch is an alternative to similar patch provided by Joe Perches.
> 
> Substitute DPRINTK macro for e_<level> that uses netdev_<level> and dev_<level>
> similar to e1000e.
> - Convert printk to pr_<level> where applicable.
> - Use common #define pr_fmt for the driver.
> - Use dev_<level> for displaying text in parts of the driver where the interface
>   name is not assigned (like e1000_param.c).
> - Better align test with the new macros.
> 
> CC: Joe Perches <joe@perches.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
