From: Peter Fassberg <pf@leissner.se>
Subject: Re: Activate netns
Date: Fri, 28 Mar 2014 01:22:14 +0100 (SNT)
Message-ID: <alpine.BSF.2.00.1403280114130.78113@nic-i.leissner.se>
References: <alpine.BSF.2.00.1403271539380.78113@nic-i.leissner.se> <53344B9C.40809@6wind.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1412300354-1115610590-1395966134=:78113"
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgate.leissner.se ([212.3.1.210]:20100 "EHLO
	mailgate.leissner.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755862AbaC1AWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 20:22:21 -0400
In-Reply-To: <53344B9C.40809@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1412300354-1115610590-1395966134=:78113
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT


On Thu, 27 Mar 2014, Nicolas Dichtel wrote:

> Le 27/03/2014 15:51, Peter Fassberg a écrit :
>> 
>> Hi!
>> 
>> I have trouble to activate netns on OpenWrt with kernel 3.8.13.
>> 
>> I get this:
>> 
>> root@ROOter:~# ip netns show
>> root@ROOter:~# ip netns add blue
>> Failed to create a new network namespace "blue": Invalid argument
>> root@ROOter:~# df
>> Filesystem           1K-blocks      Used Available Use% Mounted on
>> rootfs                   48377     10493     37884  22% /
>> /dev/root                48377     10493     37884  22% /
>> tmpfs                   257036      2264    254772   1% /tmp
>> tmpfs                      512         0       512   0% /dev
>> /dev/sda2                 4088      2266      1618  58% /mnt
>> /dev/sda1                 4088      2266      1618  58% /mnt
>> tmpfs                   257036      2264    254772   1% /tmp/run/netns
>> root@ROOter:~# uname -a
>> Linux ROOter 3.8.13 #2 Wed Mar 26 21:39:04 CET 2014 i686 GNU/Linux
>> root@ROOter:~#
>> 
>> 
>> Any hints on what I'm missing?
> Trivial question: are you sure that CONFIG_NET_NS is set?

That was my first question, and I double-checked the menuconfig *GUI*, and it was all fine, "<*>".

But now I have also checked the .config file, and there was no trace of CONFIG_KERNEL_NET_NS.

I made a clean checkout and did a new try - and it all worked!!

The config must have been messed up at some point.

Thank you for your time!

Sorry.



// Peter

---1412300354-1115610590-1395966134=:78113--
