From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: #ifdef inet_bind_bucket::ib_net
Date: Wed, 12 Nov 2008 03:16:51 -0800 (PST)
Message-ID: <20081112.031651.239477846.davem@davemloft.net>
References: <20081111111946.GD3665@x200.localdomain>
	<20081111.164554.143409564.davem@davemloft.net>
	<20081112104439.GA4292@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750886AbYKLLQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 06:16:52 -0500
In-Reply-To: <20081112104439.GA4292@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 12 Nov 2008 13:44:39 +0300

> On the other hand, people are interrupted with ctags jumping when suddenly
> whole new file appears, so loss of context is even more.

I can't remember ever reading a patch using ctags, nor actual code for
that matter.  It's not the best facility.

People read straight code.  And inline functions defined somewhere had
damn well better be named well enough to have their basic operation
or side effect be understood.

If you absolutely, positively, must know the implementation details,
you go look it up (using 'git grep' or plain 'grep', not ctags).
