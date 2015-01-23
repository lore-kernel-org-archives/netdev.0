From: Shaohua Li <shli@fb.com>
Subject: Re: net_test_tools: add ipv6 support for kbench_mod
Date: Fri, 23 Jan 2015 07:58:46 -0800
Message-ID: <20150123155846.GB631220@devbig257.prn2.facebook.com>
References: <20150114054548.GA2683397@devbig257.prn2.facebook.com>
 <20150114.013540.1963709251689177055.davem@davemloft.net>
 <20150115211737.GA2587066@devbig257.prn2.facebook.com>
 <20150115.180839.2081269036058084221.davem@davemloft.net>
 <20150122221256.GA2263247@devbig257.prn2.facebook.com>
 <54C21A9D.6080101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kafai@fb.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:53506 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755525AbbAWP6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 10:58:53 -0500
Content-Disposition: inline
In-Reply-To: <54C21A9D.6080101@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 23, 2015 at 10:55:41AM +0100, Daniel Borkmann wrote:
> On 01/22/2015 11:12 PM, Shaohua Li wrote:
> ...
> >>>Yes, we need export the sysmbol for the test. Can we export the symbol?
> >>>or I can delete the route input test, which one do you prefer?
> >>
> >>There is no justification upstream to export that symbol since
> >>there are no modular users in-tree.
> >
> >I changed it to do the ip6_route_input test optionally. If the test is
> >required, somebody should change the kernel to export it and define
> >HAVE_IP6_ROUTE_INPUT in the test module. I thought this is fine for a
> >test module. How do you think?
> 
> See above, it can only be changed/exported from the kernel as long as
> there is an in-tree module making use of it.

Yes, I mean if I want to test it, I export the symbol in my test kernel,
not for upstream.
