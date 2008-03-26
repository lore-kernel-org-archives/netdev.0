From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 3/4][NETNS][ICMP]: Make ctl tables for ICMP
 sysctls per-net.
Date: Wed, 26 Mar 2008 01:56:32 -0700 (PDT)
Message-ID: <20080326.015632.217443699.davem@davemloft.net>
References: <47EA0F98.6000207@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40099
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752884AbYCZI4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 04:56:33 -0400
In-Reply-To: <47EA0F98.6000207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 26 Mar 2008 11:55:52 +0300

> Add some flesh to ipv4_sysctl_init_net and ipv4_sysctl_exit_net,
> i.e. copy the table, alter .data pointers and register it per-net.
> 
> Other ipv4_table's sysctls are now global, but this is going to
> change once sysctl permissions patches migrate from -mm tree to 
> mainline in 2.6.26 merge window :)
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
