From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: QFQ Plus: fair-queueing service at DRR cost
Date: Tue, 20 Nov 2012 13:15:16 -0500 (EST)
Message-ID: <20121120.131516.311189144173456123.davem@davemloft.net>
References: <20121120095304.420ded7c@nehalam.linuxnetplumber.net>
	<20121120.130202.1918742054229219388.davem@davemloft.net>
	<20121120100958.010e7605@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paolo.valente@unimore.it, jhs@mojatatu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121120100958.010e7605@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 20 Nov 2012 10:09:58 -0800

> On Tue, 20 Nov 2012 13:02:02 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <shemminger@vyatta.com>
>> Date: Tue, 20 Nov 2012 09:53:04 -0800
>> 
>> > There are actually lots of bogus warnings than seem to only occur
>> > because gcc 4.4 does a bad job of checking. Later versions are fixed
>> > and don't generate warnings.
>> > 
>> > My preference is to not add the unnecessary initialization because
>> > if you get in the habit of doing it. The whole purpose of the uninitialized
>> > check is lost. 
>> 
>> Try again, this was with gcc-4.7.2-2 on Fedora.
>> 
>> There are too many preconditions, across multiple basic block, which
>> together ensure the skb is in fact initialized at the point in
>> question and the compiler simply isn't sophisticated enough to see
>> that.
> 
> Weird, it compiles  clean on x86-84 on Debian.
> gcc-4.7.real (Debian 4.7.2-4) 4.7.2

Fedora backports a lot more stuff into gcc than Debian does.
