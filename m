From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: net_test_tools: add ipv6 support for kbench_mod
Date: Fri, 23 Jan 2015 10:55:41 +0100
Message-ID: <54C21A9D.6080101@redhat.com>
References: <20150114054548.GA2683397@devbig257.prn2.facebook.com> <20150114.013540.1963709251689177055.davem@davemloft.net> <20150115211737.GA2587066@devbig257.prn2.facebook.com> <20150115.180839.2081269036058084221.davem@davemloft.net> <20150122221256.GA2263247@devbig257.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kafai@fb.com
To: Shaohua Li <shli@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754551AbbAWJzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jan 2015 04:55:47 -0500
In-Reply-To: <20150122221256.GA2263247@devbig257.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2015 11:12 PM, Shaohua Li wrote:
...
>>> Yes, we need export the sysmbol for the test. Can we export the symbol?
>>> or I can delete the route input test, which one do you prefer?
>>
>> There is no justification upstream to export that symbol since
>> there are no modular users in-tree.
>
> I changed it to do the ip6_route_input test optionally. If the test is
> required, somebody should change the kernel to export it and define
> HAVE_IP6_ROUTE_INPUT in the test module. I thought this is fine for a
> test module. How do you think?

See above, it can only be changed/exported from the kernel as long as
there is an in-tree module making use of it.
