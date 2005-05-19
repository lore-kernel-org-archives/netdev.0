From: cranium2003 <cranium2003@yahoo.com>
Subject: ip logging function help
Date: Thu, 19 May 2005 05:19:38 -0700 (PDT)
Message-ID: <20050519121938.1114.qmail@web33011.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: net dev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello,
       By adding iptable rule
iptable -A OUTPUT -j LOG
 I am able to check log of each outgoing packets. But
i want to know who is actually calling ipt_log_target
function defined in ipt_LOG.c as
static unsigned int
ipt_log_target(struct sk_buff **pskb,
               unsigned int hooknum,
               const struct net_device *in,
               const struct net_device *out,
               const void *targinfo,
               void *userinfo)

I want to know which file in source code has pointer
to call ipt_log_target function? I want instance/copy
of const struct net_device *out to my function in
kernel to know that eth0 or eth1 is transmitting
packet.
Thanks in advance.
regards,
cranium


		
Yahoo! Mail
Stay connected, organized, and protected. Take the tour:
http://tour.mail.yahoo.com/mailtour.html
