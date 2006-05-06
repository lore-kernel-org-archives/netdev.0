From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netdev: create attribute_groups with
 class_device_add
Date: Fri, 05 May 2006 18:41:58 -0700 (PDT)
Message-ID: <20060505.184158.131584956.davem@davemloft.net>
References: <20060421125255.3451959f@localhost.localdomain>
	<20060421125438.50f93a34@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:31396
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750793AbWEFBoN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 21:44:13 -0400
To: shemminger@osdl.org
In-Reply-To: <20060421125438.50f93a34@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 21 Apr 2006 12:54:38 -0700

> Atomically create attributes when class device is added. This avoids the
> race between registering class_device (which generates hotplug event),
> and the creation of attribute groups.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Did the first patch that adds the attribute_group creation
infrastructure go in so that we can get this networking fix in?
