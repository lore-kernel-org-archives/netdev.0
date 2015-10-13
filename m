From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: Pass net into defragmentation
Date: Mon, 12 Oct 2015 19:44:50 -0700 (PDT)
Message-ID: <20151012.194450.1824856588557366597.davem@davemloft.net>
References: <878u7fesrg.fsf_-_@x220.int.ebiederm.org>
	<87bnca4aie.fsf_-_@x220.int.ebiederm.org>
	<87fv1jyjcj.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	nicolas.dichtel@6wind.com
To: ebiederm@xmission.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87fv1jyjcj.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 09 Oct 2015 13:42:20 -0500

> 
> This is the next installment of my work to pass struct net through the
> output path so the code does not need to guess how to figure out which
> network namespace it is in, and ultimately routes can have output
> devices in another network namespace.
> 
> In netfilter and af_packet we defragment packets in the output path,
> and there is the usual amount of confusion about how to compute which
> net we are processing the packets in.  This patchset clears that
> confusion up by explicitly passing in struct net in ip_defrag,
> ip_check_defrag, and nf_ct_frag6_gather.
> 
> The changes are also available against net-next at:
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master

I applied this as a patch series instead of pulling, in order to
get Pablo's ACKs.

Thanks.
