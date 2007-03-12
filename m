From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] [REVISED] net/ipv4/multipath_wrandom.c: check kmalloc() return value.
Date: Mon, 12 Mar 2007 14:42:31 +0100
Message-ID: <20070312134230.GD3270@ff.dom.local>
References: <20070308.232908.92582631.davem@davemloft.net> <20070312115137.GA3270@ff.dom.local> <84144f020703120536l3967dc76o6a130edc79762350@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, amit2030@gmail.com,
	linux-kernel@vger.kernel.org, akpm@osdl.org, netdev@vger.kernel.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:52650 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965582AbXCLNiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 09:38:21 -0400
Content-Disposition: inline
In-Reply-To: <84144f020703120536l3967dc76o6a130edc79762350@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 12, 2007 at 02:36:46PM +0200, Pekka Enberg wrote:
> On 3/12/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> >So, maybe it's less evil to check those NULLs where possible and add
> >some WARN_ONs here and there...
> 
> No, it's much better to oops rather than paper over a bug.
> 

I'm not sure I can understand your intentions - do you mean
always better? In my opinion oops is right only to avoid
some danger. And here is no danger - some routing info,
which is internal multipath_xxx data and can be handled
safely, will not go into its cache.

Jarek P.
