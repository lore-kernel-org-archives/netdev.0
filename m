From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Ethernet bridge performance
Date: Thu, 7 Aug 2003 08:59:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030807085930.032b0602.shemminger@osdl.org>
References: <3F3217E7.2080903@allot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Felix Radensky <felix@allot.com>
In-Reply-To: <3F3217E7.2080903@allot.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

What kernel version?  2.6 should be faster.

On Thu, 07 Aug 2003 12:12:07 +0300
Felix Radensky <felix@allot.com> wrote:

> Hi,
> 
> I'm evaluating a performance of a dual port ethernet bridge, and the
> results are a bit disappointing. I would appreciate any hints on improving
> the results.
> 
> I'm using a Dual Xeon 2.66 GHz box based on Intel  5701 chipset with  1G
> of RAM. NICs are e1000 82546 connected to PCIX bus. Kernel is 2.4.22-pre8,
> e1000  driver version 5.1.13-k1 with NAPI support. NICs' interrupts are 
> bound
> to CPU0.
> 
> The test consists of sending 200 byte UDP packets from 2 ports of Gigabit
> IXIA traffic generator to 2 bridge ports. The bridge is capable to sustain
> the rate of ~170000 pps from each IXIA port without drops. I was
> expecting it to be able to do at least 250000 pps (our own bridge code 
>  based
> on 2.2.x kernel sustains ~266000 pps on the same hardware).
> e1000 driver drops 0 packets, all drops occur at higher level.
> 
> The output of oprofile attached. I'd be happy to provide any info you may
> need.
> 
> Thanks in advance for your help.
> 
> Felix.
> 
