From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] igbvf: avoid reset storms due to mailbox
 issues
Date: Fri, 11 Dec 2009 22:58:29 -0800 (PST)
Message-ID: <20091211.225829.246514090.davem@davemloft.net>
References: <20091212034033.10674.67054.stgit@localhost.localdomain>
	<20091212034115.10674.14928.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42113
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756041AbZLLG6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 01:58:23 -0500
In-Reply-To: <20091212034115.10674.14928.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 11 Dec 2009 19:41:16 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change makes it so that reset/interrupt storms can be avoided when
> there are mailbox issues.  The new behavior is to only allow the device to
> trigger mailbox related resets only once every 10 seconds.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
