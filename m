From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [REVISED] net/ipv4/multipath_wrandom.c: check
 kmalloc() return value.
Date: Mon, 12 Mar 2007 13:54:44 -0700 (PDT)
Message-ID: <20070312.135444.63738960.davem@davemloft.net>
References: <20070308.232908.92582631.davem@davemloft.net>
	<20070312115137.GA3270@ff.dom.local>
	<84144f020703120536l3967dc76o6a130edc79762350@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, amit2030@gmail.com, linux-kernel@vger.kernel.org,
	akpm@osdl.org, netdev@vger.kernel.org
To: penberg@cs.helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43903
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752920AbXCLUyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 16:54:46 -0400
In-Reply-To: <84144f020703120536l3967dc76o6a130edc79762350@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Date: Mon, 12 Mar 2007 14:36:46 +0200

> On 3/12/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> > So, maybe it's less evil to check those NULLs where possible and add
> > some WARN_ONs here and there...
> 
> No, it's much better to oops rather than paper over a bug.

The caller is going to OOPS in this case if you return after an
allocation failure, so there is no improvement after the patch.

Multipath-cached just sucks, it was thrown over the wall by IBM
Germany then never had any followon maintainence at all, so it will be
removed unless someone steps up to seriously maintain and fix that
code, and I REALLY MEAN IT.
