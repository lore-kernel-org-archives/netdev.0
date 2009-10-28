From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e100: Fix to allow systems with FW based
 cards to resume from STD
Date: Wed, 28 Oct 2009 04:14:04 -0700 (PDT)
Message-ID: <20091028.041404.176513002.davem@davemloft.net>
References: <20091023025904.7057.58001.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, david.graham@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37399
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752300AbZJ1LNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 07:13:40 -0400
In-Reply-To: <20091023025904.7057.58001.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 22 Oct 2009 19:59:29 -0700

> From: David Graham <david.graham@intel.com>
> 
> Devices with loadable firmware must have their firmware reloaded
> after the system resumes from sleep, but the request_firmare()
> API is not available at this point in the resume flow because
> tasks are not yet running, and the system will hang if it is
> called. Work around this issue by only calling request_firmware()
> for a device's first firmware load, and cache a copy of the pointer
> to the firmware blob for that device, so that we may reload firmware
> images even during resume.
> 
> Signed-off-by: David Graham <david.graham@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
