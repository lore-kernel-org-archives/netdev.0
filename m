From: Chuck Anderson <cra@WPI.EDU>
Subject: Re: "ping6 -M do" fragments packets
Date: Fri, 12 Oct 2007 12:32:02 -0400
Message-ID: <20071012163202.GW4751@angus.ind.WPI.EDU>
References: <20071012151841.GE3789@angus.ind.WPI.EDU> <470F9A0C.4080107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL1.WPI.EDU ([130.215.36.91]:35637 "EHLO mail1.wpi.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761994AbXJLQcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 12:32:04 -0400
Content-Disposition: inline
In-Reply-To: <470F9A0C.4080107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 12, 2007 at 06:00:12PM +0200, Patrick McHardy wrote:
> >>ping6 -M do -s 65527 www.kame.net
> > 
> > Sure enough, wireshark reports fragments:
> > 
> > No.     Time        Source                Destination           Protocol Info
> >       1 0.000000    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=0 id=0x79)
> >       2 0.000007    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=1448 id=0x79)
> 
> Are you using nf_conntrack_ipv6?

No:

nf_conntrack_tftp       9813  0 
nf_conntrack_netbios_ns     7105  0 
ipt_LOG                10305  1 
nf_conntrack_ipv4      15049  6 
xt_state                6593  6 
nf_conntrack           61001  4 nf_conntrack_tftp,nf_conntrack_netbios_ns,nf_conntrack_ipv4,xt_state
nfnetlink              10841  2 nf_conntrack_ipv4,nf_conntrack
ipt_REJECT              8641  4 
iptable_filter          6977  1 
ip_tables              16389  1 iptable_filter
ip6t_LOG               10945  1 
ip6t_REJECT             9537  2 
ip6table_filter         6849  1 
ip6_tables             17541  2 ip6t_LOG,ip6table_filter
x_tables               18757  8 ipt_LOG,xt_state,ipt_REJECT,ip_tables,ip6t_LOG,ip6t_REJECT,ip6_tables,xt_tcpudp
ipv6                  276673  51 ip6t_REJECT
