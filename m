From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pktgen: clean up ktime_t helpers
Date: Sat, 03 Nov 2012 14:52:59 -0400 (EDT)
Message-ID: <20121103.145259.1421005495138741143.davem@davemloft.net>
References: <20121028182718.GA8275@thinkbox>
	<alpine.LFD.2.02.1210281940220.2756@ionos>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dxchgb@gmail.com, xiyou.wangcong@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385Ab2KCSxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 14:53:01 -0400
In-Reply-To: <alpine.LFD.2.02.1210281940220.2756@ionos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Sun, 28 Oct 2012 19:41:02 +0100 (CET)

> On Sun, 28 Oct 2012, Daniel Borkmann wrote:
> 
>> Some years ago, the ktime_t helper functions ktime_now() and ktime_lt()
>> have been introduced. Instead of defining them inside pktgen.c, they
>> should either use ktime_t library functions or, if not available, they
>> should be defined in ktime.h, so that also others can benefit from them.
>> ktime_compare() is introduced with a similar notion as in timespec_compare().
>> 
>> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
>> Cc: Cong Wang <xiyou.wangcong@gmail.com>
>> Cc: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: Thomas Gleixner <tglx@linutronix.de>

Applied, thanks.
