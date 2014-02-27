From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: IPv6 routing table max_size badly dimensioned compared to IPv4
Date: Thu, 27 Feb 2014 21:05:23 +0100
Message-ID: <20140227200523.GA22706@xs.powerdns.com>
References: <20140227192403.GA13472@xs.powerdns.com>
 <1393531144.26794.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xs.powerdns.com ([82.94.213.34]:53111 "EHLO xs.powerdns.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051AbaB0UFZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 15:05:25 -0500
Content-Disposition: inline
In-Reply-To: <1393531144.26794.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 27, 2014 at 11:59:04AM -0800, Eric Dumazet wrote:
> What kernel version do you use ?

Thanks for the fast reply!

It calls itself "Linux node28 3.0.101-0.15-default #1 SMP Wed Jan 22
15:49:03 UTC 2014 (5c01f4e) x86_64 x86_64 x86_64 GNU/Linux"

Which is from "SLES11 SP3". I don't know how to interpret '3.0.101' compared
to 957c665f37007de93ccbe45902a23143724170d0, though.

>From what I see from git HEAD however, the number 4096 is still actually
used for things.

	Bert

> 
> I thought this was already solved.
> 
> Commit 957c665f37007de93ccbe45902a23143724170d0 is in linux 3.0
> ("ipv6: Don't put artificial limit on routing table size.")
> 
> 
> 
> 
> 
> 
