From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] ixgbe: fix memory leak when resizing rings
 while interface is down
Date: Mon, 26 Oct 2009 16:09:20 -0700 (PDT)
Message-ID: <20091026.160920.16497068.davem@davemloft.net>
References: <20091026213147.9993.9778.stgit@localhost.localdomain>
	<20091026213205.9993.32014.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55309
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754447AbZJZXI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 19:08:56 -0400
In-Reply-To: <20091026213205.9993.32014.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Oct 2009 14:32:05 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch resolves a memory leak that occurs when you resize the rings via
> the ethtool -G option while the interface is down.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
