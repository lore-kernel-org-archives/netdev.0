From: george anzinger <george@mvista.com>
Subject: Network oops
Date: Sun, 09 Jun 2002 10:31:14 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae03lg$pn4$2@main.gmane.org>
References: <200205202125.BAA03545@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, davem@redhat.com, ak@muc.de,
   pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
List-Id: netdev.vger.kernel.org

Is this sort of thing expected when the NIC is out of poop?


    <4>eth1: card reports no resources.
    <4>KERNEL: assertion ((int)tcp_packets_in_flight(tp) >=
0) failed at tcp_input.c(956):tcp_sacktag_write_queue
    <7>Leak l=8 4
    <1>Unable to handle kernel NULL pointer dereference at
virtual address 00000049
    <4> printing eip:
    <4>c025b7aa
    <1>*pde = 00000000
    <4>Oops: 0000
    <4>CPU:    0
    <4>EIP:    0010:[<c025b7aa>]    Not tainted
    <4>EFLAGS: 00010207
    <4>eax: c40d82c8   ebx: 00000000   ecx: 00000004   edx:
00000000
    <4>esi: c40d8338   edi: c40d8260   ebp: c0437eb4   esp:
c0437ea4
    <4>ds: 0018   es: 0018   ss: 0018
    <4>Process swapper (pid: 0, stackpage=c0437000)
    <4>Stack: 0000002e c40d8260 c40d8338 c40d8260 c0437ee4
c0264e8b c40d8260 00000000 
    <4>       00000001 c73cd944 00000009 c0437f10 c887250f
c40d8260 c40d8338 c0436000 
    <4>       c0437f08 c02650a6 c40d8260 c037edb8 00000094
00000000 c0437f08 c40d8260 
    <4>Call Trace: [<c0264e8b>] [<c887250f>] [<c02650a6>]
[<c01296a9>] [<c0264fc0>] 
    <4>   [<c01297ac>] [<c0124ebb>] [<c0109ae2>]
[<c01054f0>] [<c0105530>] [<c01055c2>] 
    <4>   [<c0105000>] 
    <4>
    <4>Code: 0f b6 4b 49 f6 c1 82 74 0c 31 d2 89 96 78 01 00
00 0f b6 4b 
STACK TRACE FOR TASK: 0xc0436000 (swapper)

 0 tcp_enter_loss+202 [0xc025b7aa]
 1 tcp_retransmit_timer+566 [0xc0264e86]
 2 tcp_write_timer+225 [0xc02650a1]
 3 timer_bh+710 [0xc01296a6]
 4 timer_softirq+39 [0xc01297a7]
 5 do_softirq+249 [0xc0124eb9]
 6 do_IRQ+525 [0xc0109add]
 7 do_IRQ+525 [0xc0109add]

-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
