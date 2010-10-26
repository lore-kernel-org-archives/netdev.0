From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for October 25 (netfilter/nf_conntrack_reasm)
Date: Mon, 25 Oct 2010 22:03:16 -0700 (PDT)
Message-ID: <20101025.220316.39174493.davem@davemloft.net>
References: <20101025145834.9b68e026.sfr@canb.auug.org.au>
	<20101025165529.9cedfeac.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20101025165529.9cedfeac.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Mon, 25 Oct 2010 16:55:29 -0700

> On Mon, 25 Oct 2010 14:58:34 +1100 Stephen Rothwell wrote:
> 
>> Hi all,
>> 
>> Reminder: do not add 2.6.38 destined stuff to linux-next until after
>> 2.6.37-rc1 is released.
> 
> net/ipv6/netfilter/nf_conntrack_reasm.c:628: error: 'nf_ct_frag6_sysctl_header' undeclared (first use in this function)
> net/ipv6/netfilter/nf_conntrack_reasm.c:628: error: 'nf_net_netfilter_sysctl_path' undeclared (first use in this function)
> net/ipv6/netfilter/nf_conntrack_reasm.c:629: error: 'nf_ct_frag6_sysctl_table' undeclared (first use in this function)
> net/ipv6/netfilter/nf_conntrack_reasm.c:640: error: 'nf_ct_frag6_sysctl_header' undeclared (first use in this function)
> 
> 
> config file is attached.

Should also be fixed by the commit I just pointed you to.
