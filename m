From: "J.A. =?UTF-8?B?TWFnYWxsw7Nu?=" <jamagallon@ono.com>
Subject: Performance of bonding driver with e1000
Date: Mon, 23 Nov 2009 19:06:44 +0100
Message-ID: <20091123190644.574e806c@werewolf.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp12.ono.com ([62.42.230.20]:54512 "EHLO resmaa12.ono.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754633AbZKWSLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 13:11:45 -0500
Received: from werewolf.home (83.138.217.78) by resmaa12.ono.com (8.5.113) (authenticated as jamagallon)
        id 4AFAB2F70018125B for netdev@vger.kernel.org; Mon, 23 Nov 2009 18:57:40 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi...

I have two boxes which I linked together via 2x gigabit interfaces and a
3Com switch. Each interface is:

02:0a.0 Ethernet controller: Intel Corporation 82541EI Gigabit Ethernet Controller
02:0b.0 Ethernet controller: Intel Corporation 82541EI Gigabit Ethernet Controller

I use the e1000 driver.
The switch is private for them, so there is no more taffic.
Boxes are P4-HT@2.8, 3Gb of RAM.

Both interfaces alone work pretty well (performance measured with iperf):

[  5] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 41252
[ ID] Interval       Transfer     Bandwidth
[  5]  0.0-10.0 sec  1.00 GBytes    860 Mbits/sec

[  4] local 192.168.2.2 port 5001 connected with 192.168.2.1 port 39275
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec  1024 MBytes    858 Mbits/sec

I loaded bonding driver with no parameters, and using iperf I get:

[  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 41254
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-10.0 sec    741 MBytes    621 Mbits/sec

In the node which receives, two instances of iftop on slave interfaces
show that load is balanced, but none flies higher than about 300 Mb/s.

Any ideas ?
If you guess something and need more info, I will provide it.

TIA

-- 
J.A. Magallon <jamagallon()ono!com>     \               Software is like sex:
                                         \         It's better when it's free
Mandriva Linux release 2010.0 (Cooker) for x86_64
Linux 2.6.29.3-desktop-1mnb (gcc 4.3.2 (GCC) #1 Wed May
