From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: Pass net through ip fragmention
Date: Mon, 05 Oct 2015 03:40:07 -0700 (PDT)
Message-ID: <20151005.034007.1804140165683943141.davem@davemloft.net>
References: <87fv2bo7br.fsf_-_@x220.int.ebiederm.org>
	<87si62gteh.fsf_-_@x220.int.ebiederm.org>
	<877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	nicolas.dichtel@6wind.com, pablo@netfilter.org
To: ebiederm@xmission.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 30 Sep 2015 16:24:40 -0500

> 
> This is the next installment of my work to pass struct net through the
> output path so the code does not need to guess how to figure out which
> network namespace it is in, and ultimately routes can have output
> devices in another network namespace.
> 
> This round focuses on passing net through ip fragmentation which we seem
> to call from about everywhere.  That is the main ip output paths, the
> bridge netfilter code, and openvswitch.  This has to happend at once
> accross the tree as function pointers are involved.
> 
> First some prep work is done, then ipv4 and ipv6 are converted and then
> temporary helper functions are removed.
> 
> The changes are also available against nf-next at:
> git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/net-next.git master

Pulled, thanks Eric.
