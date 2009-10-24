From: David Miller <davem@davemloft.net>
Subject: Re: Irq architecture for multi-core network driver.
Date: Fri, 23 Oct 2009 20:19:28 -0700 (PDT)
Message-ID: <20091023.201928.12664693.davem@davemloft.net>
References: <4AE0DB98.1000101@caviumnetworks.com>
	<m13a5apmm0.fsf@fess.ebiederm.org>
	<4807377b0910231028g60b479cfycdbf3f4e25384c58@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, ddaney@caviumnetworks.com,
	cfriesen@nortel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mips@linux-mips.org
To: jesse.brandeburg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59805
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751685AbZJXDTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 23:19:05 -0400
In-Reply-To: <4807377b0910231028g60b479cfycdbf3f4e25384c58@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Date: Fri, 23 Oct 2009 10:28:10 -0700

> Yes, I know Arjan and others will say you should always run
> irqbalance, but some people don't and some distros don't ship it
> enabled by default (or their version doesn't work for one reason or
> another)  The question is should the kernel work better by default
> *without* irqbalance loaded, or does it not matter?

I think requiring irqbalanced for optimal behavior is more
than reasonable.

And since we explicitly took that policy logic out of the
kernel it makes absolutely no sense to put it back there.

It's policy, and policy is (largely) userspace.
