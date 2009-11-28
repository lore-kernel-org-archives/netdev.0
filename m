From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [ tc ] RTNETLINK answers: Invalid argument
Date: Sat, 28 Nov 2009 23:14:28 +0100
Message-ID: <4B11A0C4.2040608@gmail.com>
References: <f4f837ab0911240312x329043b9y7e4694f046121237@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:1216 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbZK1WO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 17:14:59 -0500
Received: by fg-out-1718.google.com with SMTP id e12so966925fga.1
        for <netdev@vger.kernel.org>; Sat, 28 Nov 2009 14:15:04 -0800 (PST)
In-Reply-To: <f4f837ab0911240312x329043b9y7e4694f046121237@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thomas yang wrote, On 11/24/2009 12:12 PM:

> # tc filter add dev eth1 parent 1: protocol ip prio 10 u32 match ip
> src 192.168.1.0/24 flowid 1:16 action mirred egress mirror dev wlan0
> Action 3 device wlan0 ifindex 4
> RTNETLINK answers: Invalid argument
> We have an error talking to the kernel
> 
> 
> # uname -a
> Linux localhost.localdomain 2.6.30.8-64.fc11.i586 #1 SMP Fri Sep 25
> 04:30:19 EDT 2009 i686 i686 i386 GNU/Linux
> 
> OS :  Fedora 11

# tc filter add dev eth0 parent 1: protocol ip prio 10 u32 match ip
src 192.168.1.0/24 flowid 1:16 action mirred egress mirror dev wlan0
Action 3 device wlan0 ifindex 3
# uname -a
Linux ami 2.6.32-rc8g #72 PREEMPT Sat Nov 21 14:41:09 CET 2009 i686 GNU/Linux

I checked 2.6.31 too. So, generally it should work with current kernels,
at least x86_32.

Jarek P.
