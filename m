From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 3/11][IPv4] Cleanup the sysctl_net_ipv4.c
 file
Date: Wed, 05 Dec 2007 01:38:33 -0800 (PST)
Message-ID: <20071205.013833.17411286.davem@davemloft.net>
References: <4755256F.9000505@openvz.org>
	<475526B2.9040301@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35283
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751751AbXLEJie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 04:38:34 -0500
In-Reply-To: <475526B2.9040301@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 04 Dec 2007 13:06:42 +0300

> This includes several cleanups:
> 
>  * tune Makefile to compile out this file when SYSCTL=n. Now
>    it looks like net/core/sysctl_net_core.c one;
>  * move the ipv4_config to af_inet.c to exist all the time;
>  * remove additional sysctl_ip_nonlocal_bind declaration
>    (it is already declared in net/ip.h);
>  * remove no nonger needed ifdefs from this file.
> 
> This is a preparation for using ctl paths for net/ipv4/
> sysctl table.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
