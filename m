From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 15:48:31 -0700 (PDT)
Message-ID: <20120726.154831.375450579750480386.davem@davemloft.net>
References: <20120726.140601.1137230112117936793.davem@davemloft.net>
	<CAKgT0Ue4mRUpEmKA7SNpTv8D7BKcxYQ65PGoOUkxB27sLuT1Rw@mail.gmail.com>
	<20120726151312.2f3d9e02@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729Ab2GZWsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 18:48:33 -0400
In-Reply-To: <20120726151312.2f3d9e02@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 26 Jul 2012 15:13:12 -0700

> The fib trie stats are global, you may want to either disable
> CONFIG_IP_FIB_TRIE_STATS or convert them to per-cpu.

Oh yeah, turn that stuff off when testing :-)
