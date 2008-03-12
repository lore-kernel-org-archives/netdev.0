From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][NEIGH]: Fix race between pneigh deletion and ipv6's
 ndisc_recv_ns - V2
Date: Wed, 12 Mar 2008 06:12:23 -0400 (EDT)
Message-ID: <20080312.061223.82334428.yoshfuji@linux-ipv6.org>
References: <47D68817.9030709@openvz.org>
	<20080311.175212.74407707.davem@davemloft.net>
	<47D7A52D.2090007@fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xemul@openvz.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53933 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbYCLKLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 06:11:12 -0400
In-Reply-To: <47D7A52D.2090007@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <47D7A52D.2090007@fr.ibm.com> (at Wed, 12 Mar 2008 10:41:01 +0100), Daniel Lezcano <dlezcano@fr.ibm.com> says:

> Subject: [PATCH][NEIGH]: Fix race between pneigh deletion and ipv6's ndisc_recv_ns - V2
> From: Pavel Emelyanov <xemul@openvz.org>
> 
> Proxy neighbors do not have any reference counting, so any caller
> of pneigh_lookup (unless it's a netlink triggered add/del routine)
> should _not_ perform any actions on the found proxy entry. 

Good catch and I'm basically okay with this but, 
please rename neigh_check_router to pndisc_check_router().

Thanks.

--yoshfuji

