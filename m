From: anand@eis.iisc.ernet.in (SVR Anand)
Subject: Bridging woes after 3 days
Date: Sat, 29 Nov 2003 15:14:08 +0530 (GMT+05:30)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311290944.PAA27304@eis.iisc.ernet.in>
References: <20031123152601.67646dc1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20031123152601.67646dc1.davem@redhat.com> from "David S. Miller" at Nov 23, 2003 03:26:01 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

After a continous run for 3 days the bridge came down crashing with the
following kernel panic screen dump. The kernel is 2.6.0-test9-bk25 with
kernel preemption disabled. 

The following call stack is what I have seen on the console. The ethernet
cards are RTL8139. Please let me know if you want more information or finer
debugging method, I will pass it on when the bridge fails the next time.

When it worked it really worked.

Anand

----------------------------------------------------------------------------
nf_hook_slow
br_nf_pre_routing_finish
br_nf_pre_routing
br_nf_pre_finish
nf_iterate
br_handle_frame_finish
nf_hook_slow
br_handle_frame_finish
br_handle_frame
br_handle_frame_finish
netif_recieve_skb
process_backlog
net_rx_action
do_selfirq
do_IRQ
common_interrupt
default_idle
default_idle
cpu_idle
printk

code: 8b 40 18 85 c0 75 7f 85 ff 74 44 89 7b 70 0f ba 6b 40 00 89
<0> kernel panic : Fatal exception in interrupt 
In interrupt handles - not syncing	  	
----------------------------------------------------------------------------
