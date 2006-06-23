From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [1/4] kevent: core files.
Date: Fri, 23 Jun 2006 14:44:57 -0400
Message-ID: <20060623184457.GA13617@kvack.org>
References: <20060622171436.GA26161@2ka.mipt.ru> <20060623070933.GA20291@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:18345 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1751917AbWFWSqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 14:46:09 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060623070933.GA20291@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 11:09:34AM +0400, Evgeniy Polyakov wrote:
> This patch includes core kevent files:
>  - userspace controlling
>  - kernelspace interfaces
>  - initialisation
>  - notification state machines

We don't need yet another event mechanism in the kernel, so I don't see 
why the new syscalls should be added when they don't interoperate with 
existing solutions.  If your results are enough to sway akpm that it is 
worth taking the patches, then it would make sense to merge the code with 
the already in-tree APIs.

		-ben
