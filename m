From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 2/3] ipvlan: mode is u16
Date: Sun, 07 Feb 2016 14:19:11 -0500 (EST)
Message-ID: <20160207.141911.1789162712081045670.davem@davemloft.net>
References: <1454440830-2108-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902AbcBGTTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:19:14 -0500
In-Reply-To: <1454440830-2108-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Tue,  2 Feb 2016 11:20:30 -0800

> From: Mahesh Bandewar <maheshb@google.com>
> 
> The mode argument was erronusly defined as u32 but it has always
> been u16.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

This patch is changing more than this.

Specifically it is invoking ipvlan_set_port_mode() instead of assigning
port->mode directly in ipvlan_link_new().

That minimally needs to be documented in the commit log message.

But I also wonder if for some reason in this conect the direct
assignment happens to be fine.  That's pretty much why you should
explain things.
