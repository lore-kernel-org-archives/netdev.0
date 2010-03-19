From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: Fix 82599 multispeed fiber link issues
 due to Tx laser flapping
Date: Thu, 18 Mar 2010 22:14:36 -0700 (PDT)
Message-ID: <20100318.221436.258098279.davem@davemloft.net>
References: <20100319003422.8981.79416.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51733
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751264Ab0CSFOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 01:14:14 -0400
In-Reply-To: <20100319003422.8981.79416.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 18 Mar 2010 17:34:52 -0700

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Fix 82599 link issues during driver load and unload test using multi-speed
> 10G & 1G fiber modules. When connected back to back sometime 82599 multispeed
> fiber modules would link at 1G speed instead of 10G highest speed, due to a
> race condition in autotry process involving Tx laser flapping. Move autotry
> autoneg-37 tx laser flapping process from multispeed module init setup
> to driver unload. This will alert the link partner to restart its
> autotry process when it tries to establish the link with the link partner
> 
> Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
