From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] Be explict with what we are !'ing in
 ixgbe_sfp_config_module_task()
Date: Thu, 16 Apr 2009 16:27:33 -0700 (PDT)
Message-ID: <20090416.162733.121413610.davem@davemloft.net>
References: <20090416232225.18637.33348.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	akpm@linux-foundation.org, roel.kluin@gmail.com,
	tony@bakeyournoodle.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39241
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754022AbZDPX1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 19:27:41 -0400
In-Reply-To: <20090416232225.18637.33348.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 16 Apr 2009 16:22:28 -0700

> GCC warns:
> drivers/net/ixgbe/ixgbe_main.c: In function 'ixgbe_sfp_config_module_task':
> drivers/net/ixgbe/ixgbe_main.c:3920: warning: suggest parantheses around
> operand of '!' or change '&' to '&&' or '!' to '~'
> 
> Which I think is right.  Bracket to remove ambiguity.
> 
> Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
