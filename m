From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: ping6 is sent out from wrong interface
Date: Wed, 25 Jun 2008 05:04:45 +0900 (JST)
Message-ID: <20080625.050445.30187899.yoshfuji@linux-ipv6.org>
References: <485B0B1D.5000603@miraclelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org,
	yoshfuji@linux-ipv6.org
To: nooiwa@miraclelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60216 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756899AbYFXUDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 16:03:50 -0400
In-Reply-To: <485B0B1D.5000603@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <485B0B1D.5000603@miraclelinux.com> (at Fri, 20 Jun 2008 10:42:53 +0900), Naohiro Ooiwa <nooiwa@miraclelinux.com> says:

> The ping packets were sent out from "eth0"(00:19:d1:19:23:af),
> but IPv6 address was "eth1"(2001:2c0:418:2::2).
> Why is interface "eth0".  Isn't it bug ?
> 
> The following is additional information.
> 
>     # ifconfig eth0
>     eth0      Link encap:Ethernet  HWaddr 00:19:D1:19:23:AF
>               inet addr:10.1.0.161  Bcast:10.1.255.255  Mask:255.255.0.0
>               inet6 addr: 2001:2c0:418:1::1/64 Scope:Global
>               inet6 addr: fe80::219:d1ff:fe19:23af/64 Scope:Link
>               ::::::
>     # ifconfig eth1
>     eth1      Link encap:Ethernet  HWaddr 00:10:18:0E:0C:B4
>               inet addr:172.16.255.200  Bcast:172.16.255.255  Mask:255.255.0.0
>               inet6 addr: 2001:2c0:418:2::2/64 Scope:Global
>               inet6 addr: fe80::210:18ff:fe0e:cb4/64 Scope:Link
>               ::::::

-I does not specify interface strictly but source address.
Which means, if you just specify an address, interface is unspecified.
You can give "-I eth1", too.

BTW, we should accept '-I fe80::1%eth0', maybe.

--yoshfuji
