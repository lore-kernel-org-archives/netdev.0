From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ip: initialize hash list
Date: Sat, 20 Jul 2013 13:28:40 -0700
Message-ID: <1374352120.1940.7.camel@joe-AO722>
References: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
	 <20130720.122058.1139915094969451326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, pshelar@nicira.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:38895 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754923Ab3GTU2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jul 2013 16:28:42 -0400
In-Reply-To: <20130720.122058.1139915094969451326.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-07-20 at 12:20 -0700, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Sat, 20 Jul 2013 10:26:57 -0700
> 
> > +     unsigned i;
> 
> Please use an explicit "unsigned int", thank you.

Still a dozen+ of these in net
(I removed a few false positives)

$ grep -rP  --include=*.[ch] '\bunsigned\s*+(?!(int|long|char|short|\*\/))' net
net/mac80211/ieee80211_i.h:typedef unsigned __bitwise__ ieee80211_tx_result;
net/mac80211/ieee80211_i.h:typedef unsigned __bitwise__ ieee80211_rx_result;
net/ceph/osdmap.c:	unsigned len, num;
net/ceph/osdmap.c:			(unsigned)pgid.pool;
net/core/netprio_cgroup.c:static int update_netprio(const void *v, struct file *file, unsigned n)
net/rose/rose_subr.c:int rose_parse_facilities(unsigned char *p, unsigned packet_len,
net/xfrm/xfrm_policy.c:#define XFRM_QUEUE_TMO_MIN ((unsigned)(HZ/10))
net/xfrm/xfrm_policy.c:#define XFRM_QUEUE_TMO_MAX ((unsigned)(60*HZ))
net/ipv4/netfilter/nf_nat_h323.c:static int set_h245_addr(struct sk_buff *skb, unsigned protoff,
net/ipv4/ip_vti.c:	unsigned h0 = HASH(remote);
net/ipv4/ip_vti.c:	unsigned h1 = HASH(local);
net/ipv4/ip_vti.c:	unsigned h = 0;
net/sched/cls_rsvp.h:static unsigned int gen_handle(struct tcf_proto *tp, unsigned salt)
net/sched/cls_cgroup.c:static int update_classid(const void *v, struct file *file, unsigned n)
net/mac802154/wpan.c:				   unsigned len)
net/socket.c:static long sock_ioctl(struct file *file, unsigned cmd, unsigned long arg)
net/socket.c:long __sys_sendmsg(int fd, struct msghdr __user *msg, unsigned flags)
net/socket.c:long __sys_recvmsg(int fd, struct msghdr __user *msg, unsigned flags)
