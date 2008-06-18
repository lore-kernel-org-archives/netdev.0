From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPv6] Do not use loopback as source address on other
 interfaces
Date: Wed, 18 Jun 2008 22:36:00 +0900 (JST)
Message-ID: <20080618.223600.81071656.yoshfuji@linux-ipv6.org>
References: <20080618132312.GA25004@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mironov_Sergey@emc.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	yoshfuji@linux-ipv6.org
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59876 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025AbYFRNfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 09:35:10 -0400
In-Reply-To: <20080618132312.GA25004@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080618132312.GA25004@pingi.kke.suse.de> (at Wed, 18 Jun 2008 15:23:12 +0200), Karsten Keil <kkeil@suse.de> says:

> RFC 4291 forbit the use of the loopback address as source outside a node
> (paragraph 2.5.3).
> 
> The latest TAHI test release 4.0.1 does have a check for this (ICMPv6 test
> v6LC.5.1.2 Part F), so it fails currently on Linux.
> 
> Signed-off-by: Sergey Mironov <Mironov_Sergey@emc.com>
> Signed-off-by: Karsten Keil <kkeil@suse.de>

I disagree this approach - too ad-hoc fix just to pass the tests.

--yoshfuji
