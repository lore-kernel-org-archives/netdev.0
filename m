From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 22 Nov 2007 10:01:10 -0200
Message-ID: <20071122120110.GA17441@ghostprotocols.net>
References: <20071122343.446909000@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752390AbXKVMBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 07:01:21 -0500
Content-Disposition: inline
In-Reply-To: <20071122343.446909000@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, Nov 22, 2007 at 03:43:06AM +0100, Andi Kleen escreveu:
> 
> There seems to be rough consensus that the kernel currently has too many 
> exported symbols. A lot of these exports are generally usable utility 
> functions or important driver interfaces; but another large part are functions
> intended by only one or two very specific modules for a very specific purpose.
> One example is the TCP code. It has most of its internals exported, but 
> only for use by tcp_ipv6.c (and now a few more by the TCP/IP congestion modules) 
> But it doesn't make sense to include these exported for a specific module
> functions into a broader "kernel interface".   External modules assume
> they can use these functions, but they were never intended for that.

Thank you for doing this.

Creating the DCCP and its congestion control infrastructure (CCID)
module namespaces is now on my TODO list. :-)

- Arnaldo
