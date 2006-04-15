From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: RE: Fw: Openswan, iptables (fiaif) and 2.6.16 kernel
Date: Sat, 15 Apr 2006 15:00:54 +0200
Message-ID: <BAY103-F6AB914647C850A225E98AB2C10@phx.gbl>
References: <20060414105917.0db022d9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org, lcaron@apartia.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay103-f6.bay103.hotmail.com ([65.54.174.16]:24868 "EHLO
	hotmail.com") by vger.kernel.org with ESMTP id S932506AbWDONA5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 09:00:57 -0400
In-Reply-To: <20060414105917.0db022d9.akpm@osdl.org>
To: akpm@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:

>Begin forwarded message:
>
>Date: Fri, 14 Apr 2006 14:32:39 +0200
>From: Laurent CARON <lcaron@apartia.fr>
>To: linux-kernel@vger.kernel.org
>Subject: Openswan, iptables (fiaif) and 2.6.16 kernel
>
>
>Hi,
>
>I'm running an openswan gateway for quite a long time now.
>
>I have used 2.4.X and 2.6.X kernels without any problem until i decided
>to upgrade to 2.6.16 kernel.
>
>Summary of problem:
>
>Under 2.6.15 everything is fine
>
>Under 2.6.16 my tunnels establish well, but i can't even ping a single
>computer located on the other end of the tunnel when the firewall is up.
>Disabling the firewall solves the problem (but is not an option for me).
>
>$ cat ip_conntrack | grep 192.168.10
>icmp     1 8 src=192.168.0.192 dst=192.168.10.1 type=8 code=0 id=793
>packets=4 bytes=116 [UNREPLIED] src=192.168.10.1 dst=XXX.XXX.XXX.XXX
>type=0 code=0 id=793 packets=0 bytes=0 mark=0 use=1
>
>192.168.0.0/24 is my lan subnet (natted so that lan computers can access
>the internet through the public ip address)
>192.168.0.192 is a workstation on my lan
>192.168.10.0/24 is the other subnet
>XXX.XXX.XXX.XXX is my public ip address
>
>
>If i disable the nat of 192.168.0.0/24, i can ping the other end.
>
>Re-enabling the nat however disables the ability to ping the other end.
>
>Seems iptables is trying to nat packets the wrong way :$, or that I
>missed a major change in 2.6.16.
>
>Do anyone have any clue about this weiredness?
>
>Thanks
>
>Laurent

I have replied to Laurent and to openswan list:
http://lists.openswan.org/pipermail/users/2006-April/009070.html


