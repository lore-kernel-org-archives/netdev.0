From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/4] igb: do not force pcs link when in KX mode
Date: Wed, 23 Dec 2009 20:55:20 -0800 (PST)
Message-ID: <20091223.205520.229758848.davem@davemloft.net>
References: <20091223232047.16146.35264.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40577
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753132AbZLXEzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 23:55:18 -0500
In-Reply-To: <20091223232047.16146.35264.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 23 Dec 2009 15:20:47 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> We were forcing the PCS link up in error when we are in KX mode.  We should
> only be disabling autoneg, not forcing the link up.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
