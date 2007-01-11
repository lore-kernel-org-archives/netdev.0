From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [IPv6] PROBLEM? Network unreachable despite correct route
Date: Thu, 11 Jan 2007 13:53:43 +0100
Message-ID: <20070111125343.GB3561@ff.dom.local>
References: <20070110002352.GA31743@obelix.birkenwald.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:43533 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030316AbXAKMvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 07:51:48 -0500
To: Bernhard Schmidt <berni@birkenwald.de>
Content-Disposition: inline
In-Reply-To: <20070110002352.GA31743@obelix.birkenwald.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10-01-2007 01:23, Bernhard Schmidt wrote:
> On Tue, Jan 09, 2007 at 08:36:24PM +0100, Bernhard Schmidt wrote:
...
>> I'm having a really ugly problem I'm trying to pinpoint, but failed so
>> far. I'm neither completely convinced it is not related to my local
>> setup(s), nor do I have any clue how this might be caused.
...
> I managed to pull ip -6 route, ip -6 neigh and ip -6 addr while the box
> was not responding:
> 
> ip -6 route:
> 2001:4ca0:0:f000::/64 dev eth0  proto kernel  metric 256  expires 86322sec mtu 1500 advmss 1440 fragtimeout 4294967295
> fe80::/64 dev eth0  metric 256  expires 21225804sec mtu 1500 advmss 1440 fragtimeout 4294967295
> ff00::/8 dev eth0  metric 256  expires 21225804sec mtu 1500 advmss 1440 fragtimeout 4294967295
> default via fe80::2d0:4ff:fe12:2400 dev eth0  proto kernel  metric 1024  expires 1717sec mtu 1500 advmss 1440 fragtimeout 64
> unreachable default dev lo  proto none  metric -1  error -101 fragtimeout 255

Did you analyze this dev lo warning? 

Regards,
Jarek P.
