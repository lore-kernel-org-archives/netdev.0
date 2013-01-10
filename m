From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] ipv4_tunnels: Modularize ipv4 tunneling.
Date: Wed, 09 Jan 2013 23:52:39 -0800 (PST)
Message-ID: <20130109.235239.1789560948007134858.davem@davemloft.net>
References: <1357612292-1682-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, netdev@vger.kernel.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53354 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932466Ab3AJHwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 02:52:40 -0500
In-Reply-To: <1357612292-1682-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Mon,  7 Jan 2013 18:31:32 -0800

> Following patch series restructure GRE and IPIP tunneling code
> to make it modular. It adds ip_tunnel module which acts as
> generic tunneling layer which has common code. I have patch
> to do same for VXLAN too.
> 
> In Addidtion to restructuring it adds demultiplexer for ipgre
> protocol, so that linux kernel IPGRE module and OVS gre module
> can co-exist.
> Last patch adds linux state updates to tunnel device from
> lower device.

Please resubmit this when you can also submit the patches which
actually use this new modularity.

Otherwise the value proposition is impossible to analyze.

Thanks.
