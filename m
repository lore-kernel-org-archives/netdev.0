From: linux lover <linux.lover2004@gmail.com>
Subject: why packet is duplicated dev_queue_xmit_nit?
Date: Thu, 23 Dec 2004 22:28:16 +0530
Message-ID: <72c6e37904122308584977c621@mail.gmail.com>
Reply-To: linux lover <linux.lover2004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,
     I want to know what is use of dev_queue_xmit_nit function in
dev.c file? Also why it calls following statement
                      ptype->func(skb2, skb->dev, ptype);
Also why skb2 is created by cloning skb? Acually i trace TCP packets
and found that control goes from neigh_resolve_output to directly
dev_queue_xmit_nit and then to HW driver 8139too.c? I want to know why
it not goes from dev_queue_xmit? I place printk statments and found
after dev_queue_xmit_nit control moves to network interface driver?
Help to understand the control  packet path.
Thanks in advance.
linux_lover
