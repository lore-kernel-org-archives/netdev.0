From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] atl1: add napi to Atheros L1 NIC
Date: Sun, 15 Apr 2012 13:28:05 -0400 (EDT)
Message-ID: <20120415.132805.143754486571031578.davem@davemloft.net>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
	<20120415.130346.1822341707659142562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, csnook@redhat.com,
	khorenko@parallels.com
To: antonz@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754727Ab2DOR2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 13:28:11 -0400
In-Reply-To: <20120415.130346.1822341707659142562.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 15 Apr 2012 13:03:46 -0400 (EDT)

> From: Tony Zelenoff <antonz@parallels.com>
> Date: Fri, 13 Apr 2012 20:09:45 +0400
> 
>> Added NAPI interface to the driver of Atheros L1 NIC.
>> RX speed reported by iperf in TCP mode (with and without -N
>> switch) improved by ~7 Mbps. In UDP mode the speed up is
>> improved by ~4 Mbps.
>> Also hard RX/TX rings processing with memory allocation in
>> interrupt handlers is not very good idea. So, fixed this.
>> 
>> Note: thouse patches must be applied after patch, that fix
>> kernel panic in this driver.
>> Its subject is: "atl1: fix kernel panic in case of DMA errors"
> 
> Unfortunately this is bullshit.  These patches actually depend upon
> that bug fix not being applied.  Look at the patches, they reference
> and use the reset workqueue the bug fix removed.

My bad, I thought I had merged the net tree into net-next before
processing your patches but I didn't.

I just fixed this all up in the net-next tree, please double
check my work.

Thank you.
