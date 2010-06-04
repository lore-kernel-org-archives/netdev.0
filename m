From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: Use netdev_<level>, dev_<level>,
 pr_<level>
Date: Thu, 03 Jun 2010 20:04:43 -0700 (PDT)
Message-ID: <20100603.200443.104041687.davem@davemloft.net>
References: <20100604025225.16120.30293.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, joe@perches.com,
	emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44920
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932161Ab0FDDEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:04:35 -0400
In-Reply-To: <20100604025225.16120.30293.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 03 Jun 2010 19:53:41 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> This patch is alternative to a previous patch submitted by Joe Perches.
> 
> Create common macros e_<level> and e_dev_<level> that use netdev_<level> and
> dev_<level> similar to e1000e.
> Redefined pr_fmt for driver messages.
> Use %pM to display MAC address.
> Aligned text to better match the new format.
> 
> CC: Joe Perches <joe@perches.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, but:

>  /**
> - * ixgbe_get_hw_dev_name - return device name string
> + * ixgbe_get_hw_dev return device 
>   * used by hardware layer to print debugging information
>   **/

This line had trailing whitespace, which GIT warns about and I
had to remove.
