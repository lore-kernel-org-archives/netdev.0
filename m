From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 4/4] igb: check both function bits in status
 register in wol exception
Date: Wed, 23 Dec 2009 20:55:49 -0800 (PST)
Message-ID: <20091223.205549.242128476.davem@davemloft.net>
References: <20091223232047.16146.35264.stgit@localhost.localdomain>
	<20091223232145.16146.15465.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40592
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753439AbZLXEzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 23:55:47 -0500
In-Reply-To: <20091223232145.16146.15465.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 23 Dec 2009 15:21:46 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The ethtool code for enabling Wake on Lan was not correctly checking the
> status register bits so as a result ports 0 and 2 were both being allowed
> to set WOL to enabled even though it is only supported on the first port
> for our adapters.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
