From: Jeff Garzik <jgarzik@pobox.com>
Subject: TCP oopsing continues
Date: Tue, 13 Sep 2005 10:43:02 -0400
Message-ID: <4326E576.1010204@pobox.com>
References: <20050910113737.GZ22129@postel.suug.ch> <E1EE4Jh-0001iA-00@gondolin.me.apana.org.au> <20050910125010.GA22129@postel.suug.ch> <20050910194447.GA5725@gondor.apana.org.au> <20050910203131.GB22129@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Dave Jones <davej@redhat.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964799AbVIMOnP@vger.kernel.org>
To: netdev@vger.kernel.org
In-Reply-To: <20050910203131.GB22129@postel.suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Well, my oops continues in 2.6.14-rc1.  x86 SMP firewall box.

I still haven't found my null modem cable, so I don't have the top of 
the trace.  Here is everything that was on the screen:

ip_local_deliver_finish
tcp_v4_do_rcv
tcp_v4_rcv
ip_local_deliver
ip_local_deliver_finish
ip_rcv
ip_rcv_finish
netif_receive_skb
e1000_clean_rx_irq
rtl8139_isr_ack
e1000_clean
net_rx_action
__do_softirq
do_softirq
do_IRQ
