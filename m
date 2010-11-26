From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] net: Fix __inet_inherit_port() to correctly increment
 bsockets and num_owners
Date: Fri, 26 Nov 2010 18:56:07 +0300
Message-ID: <20101126155607.GA20022@ioremap.net>
References: <20101126110726.GA5648@ioremap.net>
 <174335.2288.qm@web53702.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Nagendra Tomar <tomer_iisc@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:45123 "EHLO
	tservice.net.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751566Ab0KZP4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 10:56:10 -0500
Content-Disposition: inline
In-Reply-To: <174335.2288.qm@web53702.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 26, 2010 at 03:20:31AM -0800, Nagendra Tomar (tomer_iisc@yahoo.com) wrote:
> > Frankly I did not find how those optimizations made a bug
> > as well as
> > what is this bug about from given description, but I'm glad
> > it is resolved now :)
> > 
> 
> I'm not sure of what all went into the "optimization" patch, but the bug is not due to the optimization per-se. As my original post says, it is due to the 'bsockets' and 'num_owners' not being incremented inside __inet_inherit_port(), where it should have been, as __inet_put_port() decrements them on port release, which causes the imbalance.

Argh, I see, thanks a lot for explanation!

-- 
	Evgeniy Polyakov
