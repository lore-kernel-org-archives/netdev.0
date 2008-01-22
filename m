From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in 2.6.24-rc6,
	comparing with 2.6.22
Date: Tue, 22 Jan 2008 14:51:04 +0800
Message-ID: <1200984664.3151.253.camel@ymzhang>
References: <478B9FE0.3040801@hp.com> <1200979482.3151.103.camel@ymzhang>
	 <1200982039.3151.120.camel@ymzhang>
	 <20080121.222214.184161381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:4743 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754836AbYAVGxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 01:53:15 -0500
In-Reply-To: <20080121.222214.184161381.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-01-21 at 22:22 -0800, David Miller wrote:
> From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
> Date: Tue, 22 Jan 2008 14:07:19 +0800
> 
> > I am wondering if UDP stack in kernel has a bug.
> 
> If one server binds to INADDR_ANY with port N, then any other socket
> can be bound to a specific IP address with port N.  When packets
> come in destined for port N, the delivery will be prioritized
> to whichever socket has the more specific and matching binding.
What does 'more specific' mean here? I assume 127.0.0.1 should be
prioritized before 0.0.0.0 which means packets should be queued to
127.0.0.1 firstly.

> 
> So the kernel is fine.
But kernel now queues packets to 0.0.0.0.

> 
> Netperf just needs to be more careful in order to handle this kind of
> case more cleanly.
It's better if kernel works more reasonable.

-yanmin


