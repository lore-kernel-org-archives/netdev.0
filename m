From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/4] igb: correctly offset 82575 flow control
 watermarks by 16 bytes
Date: Wed, 23 Dec 2009 20:55:40 -0800 (PST)
Message-ID: <20091223.205540.15233095.davem@davemloft.net>
References: <20091223232047.16146.35264.stgit@localhost.localdomain>
	<20091223232126.16146.13862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40587
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751115AbZLXEzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 23:55:38 -0500
In-Reply-To: <20091223232126.16146.13862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 23 Dec 2009 15:21:27 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The watermark values for the 82575 were not being set correctly.  As a
> result the high and low watermark values were set to the same value which
> can lead to excess xon/xoff packets being generated.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
