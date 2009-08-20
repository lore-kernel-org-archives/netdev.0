From: Jens Rosenboom <jens@mcbone.net>
Subject: Re: IPV6_RTHDR with a type-0 routing header
Date: Thu, 20 Aug 2009 13:29:08 +0200
Message-ID: <1250767748.9489.1.camel@fnki-nb00130>
References: <20090820111152.GA20295@uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, davem@davemloft.net, netdev@vger.kernel.org,
	shanwei@cn.fujitsu.com
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:41592 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753317AbZHTL3W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 07:29:22 -0400
In-Reply-To: <20090820111152.GA20295@uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-20 at 13:11 +0200, Steinar H. Gunderson wrote:
> Hi,
> 
> I've tried attaching a type-0 routing header to my IPv6 packets with
> setsockopt(..., IPV6_RTHDR, ...), but the kernel just returns EINVAL.
> looking at the source, it seems it simply refuses anything that's not type-2;
> should that really be right? I found the following commit:
> 
>   http://kerneltrap.org/mailarchive/linux-netdev/2008/11/11/4064594
> 
> However, it only seems to change EPERM into EINVAL. I don't see any
> reasonable explanation why it should not be simply success; in fact, RFC 3452
> only seems to talk about using type-0 headers with this option.
> 
> Any ideas?

How about RFC5095?

