From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/3] igb: fix memory leak when setting ring
 size while interface is down
Date: Mon, 26 Oct 2009 16:09:14 -0700 (PDT)
Message-ID: <20091026.160914.44259149.davem@davemloft.net>
References: <20091026213147.9993.9778.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55305
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754286AbZJZXIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 19:08:51 -0400
In-Reply-To: <20091026213147.9993.9778.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Oct 2009 14:31:47 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Changing ring sizes while the interface was down was causing a double
> allocation of the receive and transmit rings.  This issue is amplified when
> there are multiple rings enabled.  To prevent this we need to add an
> additional check which will just update the ring counts when the interface
> is not up and skip the allocation steps.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
