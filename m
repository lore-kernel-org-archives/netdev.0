From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [IPv6] PROBLEM? Network unreachable despite correct route
Date: Thu, 11 Jan 2007 14:08:16 +0100
Message-ID: <45A636C0.6050507@birkenwald.de>
References: <20070111125343.GB3561@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:43954 "EHLO mx01.mucip.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030324AbXAKNIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 08:08:21 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070111125343.GB3561@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:

>> ip -6 route:
>> 2001:4ca0:0:f000::/64 dev eth0  proto kernel  metric 256  expires 86322sec mtu 1500 advmss 1440 fragtimeout 4294967295
>> fe80::/64 dev eth0  metric 256  expires 21225804sec mtu 1500 advmss 1440 fragtimeout 4294967295
>> ff00::/8 dev eth0  metric 256  expires 21225804sec mtu 1500 advmss 1440 fragtimeout 4294967295
>> default via fe80::2d0:4ff:fe12:2400 dev eth0  proto kernel  metric 1024  expires 1717sec mtu 1500 advmss 1440 fragtimeout 64
>> unreachable default dev lo  proto none  metric -1  error -101 fragtimeout 255
> Did you analyze this dev lo warning? 

That one is default. Recent kernels (since 2.6.12 or so, I think when 
the default on-link assumption was killed) have a default route pointing 
to "unreachable default lo" on bootup. Routes learned from RA or added 
statically are installed with a better metric and are preferred that way.

I think the use is to have a Network unreachable returned immediately if 
no IPv6 router is present.

Regards,
Bernhard
