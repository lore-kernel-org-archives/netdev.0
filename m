From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: netlink receive error No buffer space available (105)
Date: Tue, 3 Jun 2008 13:54:18 +0200
Message-ID: <BAY103-DAV5D8D1E1CF45D5B9F3359DB2BA0@phx.gbl>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s14.bay0.hotmail.com ([65.54.246.150]:10867 "EHLO
	bay0-omc2-s14.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751401AbYFCLyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 07:54:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm running 'ip x mon' on linux 2.6.26-rc4
and it stop with this message after printing
few lines like these:

[...]
Async event  (0x10)  replay update
     src ...
Async event  (0x10)  replay update
     src ...
netlink receive error No buffer space available (105)

This is my ip and kernel version:

root@Venus:~# ip -V
ip utility, iproute2-ss080417
root@Venus:~# uname -a
Linux Venus 2.6.26-rc4 #1 SMP PREEMPT Tue Jun 3 13:10:36 CEST 2008 i686
Intel(R) Core(TM)2 Duo CPU     T8100  @ 2.10GHz GenuineIntel GNU/Linux

The strange thing is that on my pc (which is
an old PIII with 512MB) this problem doesn't
happen. Any hints?
TIA


