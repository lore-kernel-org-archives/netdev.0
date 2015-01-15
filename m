From: Shaohua Li <shli@fb.com>
Subject: Re: net_test_tools: add ipv6 support for kbench_mod
Date: Thu, 15 Jan 2015 13:17:37 -0800
Message-ID: <20150115211737.GA2587066@devbig257.prn2.facebook.com>
References: <20150114054548.GA2683397@devbig257.prn2.facebook.com>
 <20150114.013540.1963709251689177055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <kafai@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:16538 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751566AbbAOVRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 16:17:44 -0500
Content-Disposition: inline
In-Reply-To: <20150114.013540.1963709251689177055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 01:35:40AM -0500, David Miller wrote:
> From: Shaohua Li <shli@fb.com>
> Date: Tue, 13 Jan 2015 21:45:48 -0800
> 
> > This patch adds ipv6 support for kbench_mod test module
> 
> This doesn't even link because ip6_route_input is not an
> exported symbol.
> 
> So you either didn't test this, or it depends upon custom
> kernel changes which you didn't mention.
> 
> Either way I can't apply this, sorry

Yes, we need export the sysmbol for the test. Can we export the symbol?
or I can delete the route input test, which one do you prefer?

Thanks,
Shaohua
