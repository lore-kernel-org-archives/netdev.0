From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: Fix 82599 KX4 Wake on LAN issue after
 an improper system shutdown
Date: Thu, 18 Mar 2010 22:14:45 -0700 (PDT)
Message-ID: <20100318.221445.233713789.davem@davemloft.net>
References: <20100319011656.9385.44064.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48147
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751139Ab0CSFOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 01:14:23 -0400
In-Reply-To: <20100319011656.9385.44064.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 18 Mar 2010 18:16:56 -0700

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Advanced Power Management is disabled for 82599 KX4 connections by
> clearing GRC.APME bit, causing it to not wake the system from an
> improper system shutdown. By default GRC.APME is enabled and software
> is not supposed to clear these settings during adapter probe.
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
