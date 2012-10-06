From: David Miller <davem@davemloft.net>
Subject: Re: [net:master 1/9] pch_gbe_main.c:(.text+0x510370): undefined
 reference to `pch_ch_control_write'
Date: Sat, 06 Oct 2012 09:22:53 -0400 (EDT)
Message-ID: <20121006.092253.266767529000849292.davem@davemloft.net>
References: <20121006075954.GA29618@localhost>
	<20121006113126.GA17783@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org,
	haicheng.li@linux.intel.com, ben@decadent.org.uk
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021Ab2JFNWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 09:22:55 -0400
In-Reply-To: <20121006113126.GA17783@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 6 Oct 2012 13:31:26 +0200

> Fengguang Wu <fengguang.wu@intel.com> :
> [...]
>> FYI, kernel build failed on
>> 
>> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
>> head:   c0b8b99287235626a5850ef7e5bfc842d1ebcecd
>> commit: da1586461e53a4dd045738cce309ab488970f0ef [1/9] pch_gbe: Fix PTP dependencies.
>> config: x86_64-randconfig-s052 (attached as .config)
> 
> 7c236c43b838221e17220bcb39e8e8d8c7123713 does something like the patch
> below for the sfc driver. It would be worth checking if gianfar and
> intel get it right too.

They use select and it should work here too, I don't want to
force users to have to know about an obscure PTP chip type
in order to enable PTP for their networking card.

It should be completely hidden from them.

That's why we should use select for this.
