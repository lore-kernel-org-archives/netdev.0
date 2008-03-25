From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek RTL-8169 having receive errors
Date: Tue, 25 Mar 2008 23:10:50 +0100
Message-ID: <20080325221050.GA2277@electric-eye.fr.zoreil.com>
References: <3aa654a40803241717g218f3d51pec42ecbb29835248@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Avuton Olrich <avuton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60154 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752533AbYCYW27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 18:28:59 -0400
Content-Disposition: inline
In-Reply-To: <3aa654a40803241717g218f3d51pec42ecbb29835248@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avuton Olrich <avuton@gmail.com> :
[...]
> On my production server, I recently updated to the latest git at the
> time and I'm getting receive errors. I'd like to try to minimize the
> resets, but I'd also like to help track down this problem. Is there a
> way I can debug this, rather then downgrading back to 2.6.22.x (the
> stable kernels in between didn't work for different reasons). Thanks!
[...]
> On device:
> eth1      Link encap:Ethernet  HWaddr 00:14:85:35:CE:4D
>           inet addr:10.0.0.1  Bcast:10.0.0.0  Mask:255.255.0.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:101004007 errors:106876 dropped:0 overruns:0 frame:106876

Please increase the device verbosity level ('ethtool -s eth1 msglvl 255')
and send what appears in dmesg.

Otherwise dmesg from boot, ethtool -S output and /proc/interrupts content
for both a working 2.6.22.x and latest git could be interesting but they
may be harder to collect with a production server.

Trying the 2.6.23 driver with a 2.6.22.x kernel would help narrow the
regression too.

-- 
Ueimor
