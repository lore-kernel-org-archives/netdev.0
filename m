From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/5] e1000: fix unmap bug
Date: Tue, 30 Jun 2009 19:53:43 -0700 (PDT)
Message-ID: <20090630.195343.81852363.davem@davemloft.net>
References: <20090630224515.17771.76848.stgit@localhost.localdomain>
	<20090630224534.17771.44956.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50725
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757899AbZGACxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 22:53:37 -0400
In-Reply-To: <20090630224534.17771.44956.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Jun 2009 15:45:34 -0700

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> as reported by kerneloops.org
 ...
> Fix is to correctly zero out internal ->dma value when unmapping
> and make sure never to unmap unless there specifically was a mapping done.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
