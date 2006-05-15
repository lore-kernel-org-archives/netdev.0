From: Meelis Roos <mroos@linux.ee>
Subject: Re: ipv6 routing broken in 2.6.17-rc3,4
Date: Mon, 15 May 2006 20:38:57 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0605152035590.10949@math.ut.ee>
References: <Pine.SOC.4.61.0605150909510.29527@math.ut.ee>
 <Pine.LNX.4.64.0605151904110.12081@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:33686 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751563AbWEORjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 13:39:01 -0400
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.64.0605151904110.12081@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> vaarikas:~# ip -6 route
>> 2002:5283:297e::/48 dev tun6to4  metric 256  expires 21332659sec mtu 1480 
>> advmss 1420 hoplimit 4294967295
>
> You're using the wrong prefix length.  The right one is /16.  Does that work?

Changed tun6to4 to 2002::/16, still the same (packets for eth0 and the
unreachable destination still go to tun6to4).

# ip -6 route
::/96 via :: dev tun6to4  metric 256  expires 21334342sec mtu 1480 advmss 1420 hoplimit 4294967295
unreachable 2001:7a8:1:5::14 dev lo  metric 1024  expires 21334363sec error -101 mtu 16436 advmss 16376 hoplimit 4294967295
2002:5283:2811:2::/64 dev eth0  metric 256  expires 21334342sec mtu 1500 advmss 1440 hoplimit 4294967295
2002::/16 dev tun6to4  metric 256  expires 21334342sec mtu 1480 advmss 1420 hoplimit 4294967295
2000::/3 via ::192.88.99.1 dev tun6to4  metric 1  expires 21334342sec mtu 1480 advmss 1420 hoplimit 4294967295
fe80::/64 dev eth0  metric 256  expires 21332676sec mtu 1500 advmss 1440 hoplimit 4294967295
fe80::/64 dev eth1  metric 256  expires 21334336sec mtu 1500 advmss 1440 hoplimit 4294967295
fe80::/64 dev tun6to4  metric 256  expires 21334342sec mtu 1480 advmss 1420 hoplimit 4294967295
ff00::/8 dev eth1  metric 256  expires 21334336sec mtu 1500 advmss 1440 hoplimit 4294967295
ff00::/8 dev tun6to4  metric 256  expires 21334342sec mtu 1480 advmss 1420 hoplimit 4294967295
ff00::/8 dev eth0  metric 256  expires 21332676sec mtu 1500 advmss 1440 hoplimit 4294967295
unreachable default dev lo  proto none  metric -1  error -101 hoplimit 255

-- 
Meelis Roos (mroos@linux.ee)
