From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC PATCH net-next 1/5]IPv6:netfilter: defrag:Introduce net
 namespace
Date: Wed, 24 Feb 2010 16:26:10 +0800
Message-ID: <4B84E2A2.6020006@cn.fujitsu.com>
References: <b6fcc0a1002232348y6ff84ca8wf3bdf21de45fffbd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53590 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754849Ab0BXI0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 03:26:09 -0500
In-Reply-To: <b6fcc0a1002232348y6ff84ca8wf3bdf21de45fffbd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote, at 02/24/2010 03:48 PM:
>> -		.procname	= "nf_conntrack_frag6_timeout",
>> -		.data		= &nf_init_frags.timeout,
>> -		.maxlen		= sizeof(unsigned int),
>> -		.mode		= 0644,
>> -		.proc_handler	= proc_dointvec_jiffies,
> 
> Why are you removing sysctls?

Because, after introduced net namespace, we can use net->ipv6.frags to 
manage IPv6 conntrack fragment queue instead of nf_init_frags. 
And sysctls of ip6frag_low_thresh, ip6frag_time and ip6frag_high_thresh 
also can control IPv6 conntrack fragment queue.

So, private member of nf_init_frags becomes redundant, and remove these sysctls. 

-- 
Best Regards
-----
Shan Wei
