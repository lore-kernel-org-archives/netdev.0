From: linux lover <linux_lover2004@yahoo.com>
Subject: which are these packet types??
Date: Sat, 22 Jan 2005 20:22:09 -0800 (PST)
Message-ID: <20050123042209.23825.qmail@web52210.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,
             I have added some debug statements in
linux kernel 2.4.24 in /usr/src/linux/net/core/dev.c
printk(KERN_DEBUG "in netif_receive_skb after skb->len
= %d and address = %p\n",skb->len,skb->data);
printk(KERN_DEBUG "In netif_receive_skb
skb->nh.iph->ihl = %d && skb->nh.iph->version =
%d\n",skb->nh.iph->ihl,skb->nh.iph->version);
printk(KERN_DEBUG "packet type is =%d\n",type);
where all these 3 statemets are placed in
netif_receive_skb function of dev.c and type is
defined as unsigned short type = skb->protocol;
Then i rebuild kernel and check it on network and
found following results.

in netif_receive_skb after skb->len = 186 and address
= c75ec620
In netif_receive_skb skb->nh.iph->ihl = 0 &&
skb->nh.iph->version = 14
packet type is =1024

in netif_receive_skb after skb->len = 46 and address =
c74633a0
In netif_receive_skb skb->nh.iph->ihl = 0 &&
skb->nh.iph->version = 0
packet type is =1544

in netif_receive_skb after skb->len = 84 and address =
c7463aa0
In netif_receive_skb skb->nh.iph->ihl = 0 &&
skb->nh.iph->version = 14
packet type is =1024

in netif_receive_skb after skb->len = 100 and address
= c74639a0
In netif_receive_skb skb->nh.iph->ihl = 0 &&
skb->nh.iph->version = 14
packet type is =1024

in netif_receive_skb after skb->len = 78 and address =
c7463aa0
In netif_receive_skb skb->nh.iph->ihl = 5 &&
skb->nh.iph->version = 4
packet type is =8

I want to know which are these packet types?
I know only values 8 for IP and 2054 for ARP packets
then which are these packets 1024,1544.
regards,
linux_lover


		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - now with 250MB free storage. Learn more.
http://info.mail.yahoo.com/mail_250
