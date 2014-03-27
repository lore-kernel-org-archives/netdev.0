From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Activate netns
Date: Thu, 27 Mar 2014 09:06:24 -0700
Message-ID: <1395936384.12610.302.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.BSF.2.00.1403271539380.78113@nic-i.leissner.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Fassberg <pf@leissner.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:37343 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304AbaC0QG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:06:26 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so3664757pab.36
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 09:06:26 -0700 (PDT)
In-Reply-To: <alpine.BSF.2.00.1403271539380.78113@nic-i.leissner.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-27 at 15:51 +0100, Peter Fassberg wrote:
> Hi!
> 
> I have trouble to activate netns on OpenWrt with kernel 3.8.13.
> 
> I get this:
> 
> root@ROOter:~# ip netns show
> root@ROOter:~# ip netns add blue
> Failed to create a new network namespace "blue": Invalid argument
> root@ROOter:~# df
> Filesystem           1K-blocks      Used Available Use% Mounted on
> rootfs                   48377     10493     37884  22% /
> /dev/root                48377     10493     37884  22% /
> tmpfs                   257036      2264    254772   1% /tmp
> tmpfs                      512         0       512   0% /dev
> /dev/sda2                 4088      2266      1618  58% /mnt
> /dev/sda1                 4088      2266      1618  58% /mnt
> tmpfs                   257036      2264    254772   1% /tmp/run/netns
> root@ROOter:~# uname -a
> Linux ROOter 3.8.13 #2 Wed Mar 26 21:39:04 CET 2014 i686 GNU/Linux
> root@ROOter:~#
> 
> 
> Any hints on what I'm missing?
> 

Are you sure kernel was compiled with netns support ?

CONFIG_NET_NS=y
