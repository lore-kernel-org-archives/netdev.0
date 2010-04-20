From: Ben Greear <greearb@candelatech.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount
 	of outgoing connections (unable to bind ... )
Date: Tue, 20 Apr 2010 16:49:33 -0700
Message-ID: <4BCE3D8D.3030500@candelatech.com>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>	 <4BCE33B9.8050101@candelatech.com>	 <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>	 <4BCE392F.60104@candelatech.com> <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Gaspar Chilingarov <gasparch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49465 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab0DTXtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:49:36 -0400
In-Reply-To: <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2010 04:35 PM, Gaspar Chilingarov wrote:
> sysctl -a | grep local_port_range

[root@ct503-10G-09 ~]# sysctl -a | grep local_port_range
net.ipv4.ip_local_port_range = 10000	61000

I'm explicitly binding to local ports as well as local IPs, btw.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
