From: linux lover <linux.lover2004@gmail.com>
Subject: what is use of dev_queue_xmit_nit?
Date: Tue, 21 Dec 2004 15:36:14 +0530
Message-ID: <72c6e379041221020653e7a488@mail.gmail.com>
Reply-To: linux lover <linux.lover2004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
Sender: linux-net-owner@vger.kernel.org
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
