From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: Activate netns
Date: Thu, 27 Mar 2014 17:02:36 +0100
Message-ID: <53344B9C.40809@6wind.com>
References: <alpine.BSF.2.00.1403271539380.78113@nic-i.leissner.se>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Peter Fassberg <pf@leissner.se>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:64500 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351AbaC0QCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:02:39 -0400
Received: by mail-we0-f176.google.com with SMTP id x48so1875912wes.7
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 09:02:38 -0700 (PDT)
In-Reply-To: <alpine.BSF.2.00.1403271539380.78113@nic-i.leissner.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/03/2014 15:51, Peter Fassberg a =E9crit :
>
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
> tmpfs                   257036      2264    254772   1% /tmp/run/netn=
s
> root@ROOter:~# uname -a
> Linux ROOter 3.8.13 #2 Wed Mar 26 21:39:04 CET 2014 i686 GNU/Linux
> root@ROOter:~#
>
>
> Any hints on what I'm missing?
Trivial question: are you sure that CONFIG_NET_NS is set?


Regards,
Nicolas
