From: "Jon Fraser" <J_Fraser@bit-net.com>
Subject: RE: [Question] SMP for Linux
Date: Thu, 24 Oct 2002 17:00:51 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <001701c27ba0$6ff02c70$3701020a@CONCORDIA>
References: <15793.3958.926796.634263@robur.slu.se>
Reply-To: <J_Fraser@bit-net.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
In-Reply-To: <15793.3958.926796.634263@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>  Hope to verify this for "kfree-route" test. Did you use oprofile
>  for performance counters?

I used perfctr-2.4.0-pre2 to grab the CPU performance counters.
I was interested in cache invalidates, etc.

I guess I'll try using oprofile to see where in the code I'm really 
spending the time.

> 
>  > I'll repeat the same tests on Monday with 82543 based cards.
>  > I would expect similar results.
>  > Oh, I used top and vmstat to collect cpu percentages, 
> interrupts/second,
> 
>  Hmm top and vmstat doesn't give you time spent in 
> irq/softirq's except for 
>  softirq's run via ksoftird?

Right.
