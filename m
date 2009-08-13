From: Joe Perches <joe@perches.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 14:13:42 -0700
Message-ID: <1250198022.28285.133.camel@Joe-Laptop.home>
References: <1250091560.6641.48.camel@fnki-nb00130>
	 <4A836D6D.1040400@hp.com> <1250174390.6641.89.camel@fnki-nb00130>
	 <4A843EF7.4010700@hp.com> <1250187034.28285.93.camel@Joe-Laptop.home>
	 <4A847669.7050508@hp.com> <1250195675.28285.128.camel@Joe-Laptop.home>
	 <457D0D34-041E-43AE-BE31-241A19AA08B4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, Jens Rosenboom <jens@mcbone.net>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:4290 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161AbZHMVNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 17:13:51 -0400
In-Reply-To: <457D0D34-041E-43AE-BE31-241A19AA08B4@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-13 at 17:02 -0400, Chuck Lever wrote:
> On Aug 13, 2009, at 4:34 PM, Joe Perches wrote:
> > net/sunrpc/svcauth_unix.c:		seq_printf(m, "%s %pI6 %s\n", im- 
> > >m_class, &addr, dom);
> 
> This one might be a bad example.

There are 9 of them in net

$ grep -rP --include=*.[ch] "%pI6" net | grep seq_ 
net/sctp/ipv6.c:	seq_printf(seq, "%pI6 ", &addr->v6.sin6_addr);
net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c:	return seq_printf(s, "src=%pI6 dst=%pI6 ",
net/ipv6/ip6mr.c:		seq_printf(seq, "%pI6 %pI6 %-3hd",
net/netfilter/xt_hashlimit.c:		return seq_printf(s, "%ld %pI6:%u->%pI6:%u %u %u %u\n",
net/netfilter/xt_recent.c:		seq_printf(seq, "src=%pI6 ttl: %u last_seen: %lu oldest_pkt: %u",
net/netfilter/ipvs/ip_vs_ctl.c:				seq_printf(seq, "%s  [%pI6]:%04X %s ",
net/netfilter/ipvs/ip_vs_conn.c:			seq_printf(seq, "%-3s %pI6 %04X %pI6 %04X %pI6 %04X %-11s %7lu\n",
net/netfilter/ipvs/ip_vs_conn.c:			seq_printf(seq, "%-3s %pI6 %04X %pI6 %04X %pI6 %04X %-11s %-6s %7lu\n",
net/sunrpc/svcauth_unix.c:		seq_printf(m, "%s %pI6 %s\n", im->m_class, &addr, dom);

> [ I would think user space in general should be using inet_pton(3)  
> everywhere for such interfaces, so the format of these addresses  
> wouldn't matter so much.  Probably impossible at this point. ]

David Miller is authoritative here.

> I'm not arguing one way or the other, but it would be useful if  
> someone could check exactly what the dependencies are right now.  It  
> seems like we're speculating a bit.

cheers, Joe

