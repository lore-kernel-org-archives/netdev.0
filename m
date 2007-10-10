From: "Denys" <denys@visp.net.lb>
Subject: Re: Possible 2.6.22 -> 2.6.23 HTB regression?
Date: Wed, 10 Oct 2007 16:20:38 +0300
Message-ID: <20071010132039.M920@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: kaber@trash.net, hadi@cyberus.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:47845 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbXJJNcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 09:32:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I did complete reboot(without kexec) to 2.6.23 (same configuration) and seems 
it is working better (not stuck as before to 60-70Mbit/s).

On all cases current_clocksources was hpet, just i tried to change it (doesnt 
help at all).

visp-1 ~ # cat /sys/devices/system/clocksource/clocksource0/
current_clocksource
hpet
visp-1 ~ # cat /sys/devices/system/clocksource/clocksource0/
available_clocksource
hpet acpi_pm jiffies tsc

from pcap analyser i wrote (just filter by expression "ip" counting bytes on 
eth0.1000):

82957/82957 KBit/S (53092530/53092530) (3887135786/3889389904)
82931/82931 KBit/S (53076469/53076469) (3940228316/3942482434)
82965/82965 KBit/S (53097615/53097615) (3993304785/3995558903)
82946/82946 KBit/S (53085988/53085988) (4046402400/4048656518)
82867/82867 KBit/S (53035341/53035341) (4099488388/4101742506)
82941/82941 KBit/S (53082260/53082260) (4152523729/4154777847)
82952/82952 KBit/S (53089348/53089348) (4205605989/4207860107)
82948/82945 KBit/S (53086915/53085415) (4258695337/4260949455)


visp-1 ~ # cat /proc/net/psched
000003e8 00000400 000f4240 3b9aca00

How i can help more?

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

