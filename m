From: linux lover <linux_lover2004@yahoo.com>
Subject: Analysing UDP packet building code in 2.6.10 kernel
Date: Sun, 16 Jan 2005 05:00:58 -0800 (PST)
Message-ID: <20050116130058.69965.qmail@web52210.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,
         I am knowing all 2.4 kernel network stack
packet buildup procedure. Now i am trying to analysing
same in
2.6.10 kernel. What i found is many changes to 2.6
kernel compare to 2.4. Theres is no ip_build_xmit
instead thers a new function that is
ip_append_data. What i want to know is from udp.c
file. Theres a udp protocol structure is defined
struct proto udp_prot = {
 	.name =		"UDP",
	.owner =	THIS_MODULE,
	.close =	udp_close,
	.connect =	ip4_datagram_connect,
	.disconnect =	udp_disconnect,
	.ioctl =	udp_ioctl,
	.destroy =	udp_destroy_sock,
	.setsockopt =	udp_setsockopt,
	.getsockopt =	udp_getsockopt,
	.sendmsg =	udp_sendmsg,
	.recvmsg =	udp_recvmsg,
	.sendpage =	udp_sendpage,
	.backlog_rcv =	udp_queue_rcv_skb,
	.hash =		udp_v4_hash,
	.unhash =	udp_v4_unhash,
	.get_port =	udp_v4_get_port,
	.slab_obj_size = sizeof(struct udp_sock),
};

I want to know for what purpose udp_sendpage is used
also whats significance of . in structure members?
Also why .slab_obj_size = sizeof(struct udp_sock)
defined in udp_prot?
Also where's packet size/space is allocated for UDP
packet?
Please help me to analyze code.
Thanks in advance.
linux_lover.



		
__________________________________ 
Do you Yahoo!? 
The all-new My Yahoo! - Get yours free! 
http://my.yahoo.com 
 
