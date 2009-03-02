From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: some tc commands fail on 2.6.29-rc6-git5, works on 2.6.28.7
Date: Sun, 1 Mar 2009 16:57:29 -0800
Message-ID: <20090301165729.8e08e1d7.akpm@linux-foundation.org>
References: <a5d9929e0903011636w6bff1032y28ab58c0ff8c8052@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Joao Correia <joaomiguelcorreia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46780 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753777AbZCBA5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 19:57:34 -0500
In-Reply-To: <a5d9929e0903011636w6bff1032y28ab58c0ff8c8052@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(cc netdev)

On Mon, 2 Mar 2009 00:36:03 +0000 Joao Correia <joaomiguelcorreia@gmail.com> wrote:

> Hello all
> 
> On a Fedora 9 box, with a 2.6.29-rc6-git5 compiled with the same
> .config as the previously running 2.6.28.7, i get:
> 
> [root@duron ~]# /sbin/tc qdisc add dev eth2 handle ffff: ingress
> [root@duron ~]# /sbin/tc filter add dev eth2 parent ffff: protocol ip
> prio 50 u32 match ip src 0.0.0.0/0 police rate 30320kbit burst 500k
> drop flowid :1
> RTNETLINK answers: Invalid argument
> We have an error talking to the kernel
> [root@duron ~]# uname -a
> Linux duron 2.6.29-rc6-git5 #3 SMP Sun Mar 1 00:02:56 WET 2009 i686
> athlon i386 GNU/Linux
> [root@duron ~]#
> 
> There is no information regarding this event on dmesg or /var/log/messages.
> eth2 exists and is working properly, under 2.6.28.7 it works (without
> complaints).
> 
> Please advise on what steps I may take to provide more information. I have
> both kernel sources and availability to apply patches/recompile as needed.
> 

