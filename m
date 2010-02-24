From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH net-next 1/5]IPv6:netfilter: defrag:Introduce net
 namespace
Date: Wed, 24 Feb 2010 15:05:15 +0100
Message-ID: <4B85321B.1090003@trash.net>
References: <b6fcc0a1002232348y6ff84ca8wf3bdf21de45fffbd@mail.gmail.com> <4B84E2A2.6020006@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44188 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755578Ab0BXOFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 09:05:18 -0500
In-Reply-To: <4B84E2A2.6020006@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shan Wei wrote:
> Alexey Dobriyan wrote, at 02/24/2010 03:48 PM:
>>> -		.procname	= "nf_conntrack_frag6_timeout",
>>> -		.data		= &nf_init_frags.timeout,
>>> -		.maxlen		= sizeof(unsigned int),
>>> -		.mode		= 0644,
>>> -		.proc_handler	= proc_dointvec_jiffies,
>> Why are you removing sysctls?
> 
> Because, after introduced net namespace, we can use net->ipv6.frags to 
> manage IPv6 conntrack fragment queue instead of nf_init_frags. 
> And sysctls of ip6frag_low_thresh, ip6frag_time and ip6frag_high_thresh 
> also can control IPv6 conntrack fragment queue.
> 
> So, private member of nf_init_frags becomes redundant, and remove these sysctls. 

You can't simply remove them without a warning, people might be
using them.

