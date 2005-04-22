From: Chris Friesen <cfriesen@nortel.com>
Subject: Re: 2.6.9 BUG in tcp_transmit_skb at net/ipv4/tcp_output.c -- full
 output
Date: Fri, 22 Apr 2005 09:56:44 -0600
Message-ID: <42691EBC.9040106@nortel.com>
References: <42691CC3.7000108@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <42691CC3.7000108@nortel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here's the full output of the bug

kernel BUG in tcp_transmit_skb at net/ipv4/tcp_output.c:277!
Oops: Exception in kernel mode, sig: 5 [#1]
SMP NR_CPUS=2
NIP: C00000000033D538 XER: 0000000000000000 LR: C00000000033CAEC
REGS: c00000012d91f410 TRAP: 0700   Not tainted  (2.6.9)
MSR: 9000000000029032 EE: 1 PR: 0 FP: 0 ME: 1 IR/DR: 11
TASK: c00000016c8e6ae0[1211] 'peel' THREAD: c00000012d91c000 CPU: 0
GPR00: 0000000000000001 C00000012D91F6E0 C000000000623A60 FFFFFFFFFFFFFF97
GPR04: C000000123582980 0000000000000000 0000000000000000 0000000000000000
GPR08: 0000000000000000 0000000000000000 0000000000000001 C00000000FFC2900
GPR12: C000000123582980 C000000000492400 0000000000000001 000000001C0D9EE8
GPR16: 0000000000000000 0000000000000001 0000000000001015 0000000000009F5C
GPR20: 0000000000000005 0000000000000005 000000000000008F C00000016CA9E3D8
GPR24: 0000000000000020 C0000001235829F0 C00000016CA9E180 C000000123582980
GPR28: C00000016CA9E180 0000000000000218 C000000000530650 C00000016CA9E488
NIP [c00000000033d538] .tcp_transmit_skb+0x7c/0xa44
LR [c00000000033caec] .tcp_rcv_state_process+0xdb4/0x13bc
Call Trace:
[c00000012d91f6e0] [0000000000000028] 0x28 (unreliable)
[c00000012d91f800] [c00000000033caec] .tcp_rcv_state_process+0xdb4/0x13bc
[c00000012d91f920] [c000000000347190] .tcp_v4_do_rcv+0x164/0x434
[c00000012d91f9f0] [c0000000002fee64] .__release_sock+0x78/0xc4
[c00000012d91fa90] [c0000000002fef38] .release_sock+0x88/0xdc
[c00000012d91fb10] [c000000000359cb0] .inet_stream_connect+0x90/0x3ac
[c00000012d91fc20] [c0000000002fc9c8] .sys_connect+0x94/0xc8
[c00000012d91fd40] [c000000000319710] .compat_sys_socketcall+0x134/0x2ac
[c00000012d91fde0] [c000000000010434] syscall_exit+0x0/0x18
<0>Kernel panic - not syncing: Fatal exception in interrupt
<0>Rebooting in 180 seconds..
