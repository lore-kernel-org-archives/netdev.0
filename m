From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] net: Allow accepted sockets to be
 bound to l3mdev domain
Date: Fri, 18 Dec 2015 14:44:00 -0500 (EST)
Message-ID: <20151218.144400.647630972937662772.davem@davemloft.net>
References: <1450300844-11010-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932554AbbLRToC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 14:44:02 -0500
In-Reply-To: <1450300844-11010-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 16 Dec 2015 13:20:42 -0800

> Allow accepted sockets to derive their sk_bound_dev_if setting from the
> l3mdev domain in which the packets originated. This version adds a sysctl
> to control whether the setting is inherited, making the functionality
> similar to sk_mark and its sysctl_tcp_fwmark_accept setting.
> 
> This effectively allow a process to have a "VRF-global" listen socket,
> with child sockets bound to the VRF device in which the packet originated.
> A similar behavior can be achieved using sk_mark, but a solution using marks
> is incomplete as it does not handle duplicate addresses in different L3
> domains/VRFs. Allowing sockets to inherit the sk_bound_dev_if from l3mdev
> domain provides a complete solution.

Series applied, thanks David.
