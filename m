From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [Patch 1/1][RFC] NETDEV: Find network bugs by validating the
	sk_buff state
Date: Wed, 29 Apr 2009 08:14:40 -0700
Message-ID: <20090429151440.GA14266@cuplxvomd02.corp.sa.net>
References: <20090429040501.GA32074@cuplxvomd02.corp.sa.net> <20090428.223058.119960146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:3685 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851AbZD2POq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 11:14:46 -0400
Content-Disposition: inline
In-Reply-To: <20090428.223058.119960146.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 28, 2009 at 10:30:58PM -0700, David Miller wrote:
> 
> Sorry, for this to be useful distributions are going to turn it on by
> default, and adding 24 bytes to struct sk_buff on 64-bit when we're
> trying everything in our power to make it smaller rather than larger
> is not acceptable.

That's like saying that any of the kernel debugging options have to be on
by default.  I expect that most folks won't want this on unless they are
looking for a bug. 

> It's a useful change, something to keep in one's back pocket when
> debugging something, but not for upstream, sorry.

Right. This is why it depends on KERNEL_DEBUG and why it is off by default.

David VomLehn
