From: Rick Jones <rick.jones2@hp.com>
Subject: Re: A question about MTUs and TCP stack
Date: Fri, 19 Aug 2011 10:33:38 -0700
Message-ID: <4E4E9E72.6090105@hp.com>
References: <A55791AD2520D54CA92150D16630D03B36116A5B@VA3DIAXVS1F1.RED001.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pawan Singh <psingh@silver-peak.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:41217 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756376Ab1HSRdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 13:33:40 -0400
In-Reply-To: <A55791AD2520D54CA92150D16630D03B36116A5B@VA3DIAXVS1F1.RED001.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2011 11:33 AM, Pawan Singh wrote:
> Hi
>
> I am posting this question to "netdev" mailing list because I could
> no longer find "linux-net" mailing list.
>
> I find that the Linux TCP stack consumes huge amount of CPU if the
> MTU of an interface is set to 2400 and it is receiving 1000 byte
> Ethernet packets. On the other hand, if the MTU is set to 1500, the
> CPU consumption is reduced drastically. Increased CPU usage causes
> network throughput to drop considerably (from 800-900 Mbps to 200
> Mbps). My kernel version is fedora core 6 and we are using 1 Gig NICs
> (Intel 82546GB and Broadcom NetXtreme BCM5721):
>
> Linux he7700-tg 2.6.22.14-72.fc6 #1 SMP Wed Nov 21 14:10:25 EST 2007
> x86_64 x86_64 x86_64 GNU/Linux

Based on my experience, you are best off using much more contemporary 
kernels when bringing things to the attention of the netdev list.  The 
list is much more concerned with current bits than those from years past.

Issues with bits from years past are probably best addressed towards the 
distro(s) using them, if any.

Looking into getting a oprofile profile of the behaviour, particularly 
if it still exists in a contemporary kernel would probably be a good idea.

Also good ideas would be checking the netstat statistics before and 
after a test run, and looking at packet traces.  You want to look for 
things like stats on collapsing buffers and packets being dropped.

rick jones

>
> I do not know the TCP buffer management internals and how they are
> affected by MTU. Is there some FAQ/information online or do I have to
> open up the source code and try to identify the source of the
> problem. I guess I can also try newer versions of the kernel and see
> if the issue has been resolved.
>
> -Pawan
