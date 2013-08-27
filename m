From: Andrew Brooks <arb@sat.dundee.ac.uk>
Subject: Re: niu lock-up (Transmit timed out, resetting) and NETDEV WATCHDOG
Date: Tue, 27 Aug 2013 16:01:25 +0100
Message-ID: <CAHOfOo2jn==97EQ4ka7CdBf9UGfEhtZrs-22YB+HgV=8Z0FqUg@mail.gmail.com>
References: <CAHOfOo21+hSwFrXZuoMppcivcOonhx-m1p-yyZsm6c5UCh0joQ@mail.gmail.com>
 <CAHOfOo0kdByd3T0LL4tBpy-aFtJS6bRK7D=rPc6Si0iv03CLKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Net-Dev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHOfOo0kdByd3T0LL4tBpy-aFtJS6bRK7D=rPc6Si0iv03CLKQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

> On 26 March 2013 13:44, Andrew Brooks <arb@sat.dundee.ac.uk> wrote:
>> Using niu driver for this card: Oracle/SUN Multithreaded 10-Gigabit
>> Ethernet Network Controller and after a period the interface will hang
>> with errors every 5 seconds
>> "niu: xxx: eth2: Transmit timed out, resetting"

Here's more information about the problem:
When the interface hangs we see these messages from the driver:

[3408740.816032] niu: niu_interrupt() ldg[ffff8807141d16d0](18)
v0[8000000000] v1[0] v2[0]
[3408740.816036] niu 0000:09:00.0: eth2: niu_txchan_intr() cs[b860b860000c000]
[3408740.816038] niu 0000:09:00.0: eth2: niu_poll_core() v0[0000008000000000]
[3408740.816040] niu 0000:09:00.0: eth2: niu_tx_work() pkt_cnt[0] cons[119]
[3408740.816042] niu: niu_interrupt() ldg[ffff8807141d16d0](18)
v0[8000000000] v1[0] v2[0]
[3408740.820004] [sched_delayed] sched: RT throttling activated
[3408740.824021] niu 0000:09:00.0: eth2: Disable interrupts
[3408740.824044] niu 0000:09:00.0: eth2: Disable RX MAC
[3408740.824048] niu 0000:09:00.0: eth2: Disable IPP
[3408740.824054] niu 0000:09:00.0: eth2: Stop TX channels
[3408740.824641] niu 0000:09:00.0: eth2: Stop RX channels
[3408740.824652] niu 0000:09:00.0: eth2: Reset TX channels
[3408740.825212] niu 0000:09:00.0: eth2: Reset RX channels
[3408740.825999] niu 0000:09:00.0: eth2: Initialize TXC
[3408740.826002] niu 0000:09:00.0: eth2: Initialize TX channels

However the interface doesn't recover :-(
Are there any clues there?

Thanks!
