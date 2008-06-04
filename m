From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-2.6] IPv6 fixes.
Date: Thu, 05 Jun 2008 04:17:39 +0900 (JST)
Message-ID: <20080605.041739.35779908.yoshfuji@linux-ipv6.org>
References: <20080604.120250.131119978.yoshfuji@linux-ipv6.org>
	<48460DDC.4040703@cn.fujitsu.com>
	<4846E012.9020300@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58118 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341AbYFDTRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 15:17:02 -0400
In-Reply-To: <4846E012.9020300@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <4846E012.9020300@hp.com> (at Wed, 04 Jun 2008 14:33:54 -0400), Brian Haley <brian.haley@hp.com> says:

> With patch, differences shown with **:
> 
> src/ifindex	result
> -----------	------
> 
> ::/0		SUCCESS (packet sent on lo)
> ::/1 (lo)	SUCCESS (packet sent on lo)
> ::/3 (eth0)	SUCCESS (packet sent on lo)
> ::/27		ENODEV **
> 
> ::1/0		SUCCESS (packet sent on lo)
> ::1/1 (lo)	SUCCESS (packet sent on lo)
> ::1/3 (eth0)	EINVAL **
> ::1/27		ENODEV **
> 
> ff02::1/0	EINVAL
> ff02::1/1	EINVAL
> ff02::1/3	EINVAL
> ff02::1/27	ENODEV

At least it is expected, and reasonable to me.

--yoshfuji
