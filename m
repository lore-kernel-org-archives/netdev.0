From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2] ixgbe:add support for a new 82599 10G
 Base-T device
Date: Thu, 20 May 2010 23:07:15 -0700 (PDT)
Message-ID: <20100520.230715.237337007.davem@davemloft.net>
References: <20100519224607.2802.52952.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51819
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932435Ab0EUGHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 02:07:06 -0400
In-Reply-To: <20100519224607.2802.52952.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 19 May 2010 15:46:09 -0700

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> This adds support for a new copper device for 82599, device id 0x151c.
> This 82599 10GBase-T device uses the PHY's internal temperature sensor
> to guard against over-temp conditions. In this scenario the PHY will be
> put in a low power mode and link will no longer be able to transmit or
> receive any data. When this occurs, the over-temp interrupt is latched
> and driver logs this error message. A HW reset or power cycle is
> required to clear this status.
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
