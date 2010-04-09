From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH 0/2] netdev: Add tracepoint to network/driver
 interface
Date: Fri, 9 Apr 2010 07:04:20 -0400
Message-ID: <20100409110420.GA16609@hmsreliant.think-freely.org>
References: <4BBED951.8040406@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com,
	kaneshige.kenji@jp.fujitsu.com, davem@davemloft.net
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43416 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab0DILE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 07:04:26 -0400
Content-Disposition: inline
In-Reply-To: <4BBED951.8040406@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 09, 2010 at 04:37:53PM +0900, Koki Sanagi wrote:
> These patches add tracepoints to network/driver interface.
> 
> These tracepoints are helpful to investigate whether a packet passes or not.
> For example, when Heart Beat is disconnected, that information is helpful
> to investigate the cause is whether driver/device side or not.
> 
> An output is below.
> 
>   sshd-2443  [001] 68238.415621: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114
> <idle>-0     [001] 68238.417058: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=52
> <idle>-0     [001] 68238.704363: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=100
>   sshd-2443  [001] 68238.705459: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114
> <idle>-0     [001] 68238.706891: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=52
> <idle>-0     [001] 68238.878736: netdev_receive_skb: dev=eth3 skbaddr=f3c81540 len=100
>   sshd-2443  [001] 68238.880361: netdev_start_xmit: dev=eth3 skbaddr=f3db5138 len=114
> 
> As other use case I have, we can get throughput per interface with some sort of
> perf scripts. I plan to create it.
> 
> Thanks
> Koki Sanagi
> 
You can get a reasonable estimate of per-interface throughput using ethtool or
even ifconfig in a script.  What are the tracepoints needed for that?  Don't get
me wrong, I think these tracepoints could have some potential use thats not
covered by other tools, I just don't see the above as a conclusive reason to add
them.

Regards
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
