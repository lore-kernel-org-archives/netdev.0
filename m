From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: netdev->priv and netdev_priv(dev)
Date: Tue, 29 Jan 2008 22:52:02 +0100
Message-ID: <m3bq74uwot.fsf@maximus.localdomain>
References: <m3tzkwv1ev.fsf@maximus.localdomain>
	<20080129124259.7c502d13@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:39829 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753376AbYA2VwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 16:52:05 -0500
In-Reply-To: <20080129124259.7c502d13@deepthought> (Stephen Hemminger's message of "Tue\, 29 Jan 2008 12\:42\:59 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> Those drivers were making a incorrect assumption and should be fixed.
> The in-tree drivers were fixed when this was done. If you have an out
> of tree driver, then too bad for you.

I have few out-of-tree drivers (IOW not yet merged) but they aren't
affected. These in the tree are (actually I was contacted by driver's
author and am considering the best way to fix this).

> The additional overhead of the address calculation would slow down the
> well behaved drivers.

There is always dev->priv.

> There was discussion of alternative layouts of
> the network device allocation or limiting the number of subqueue's so
> that netdev_priv could be a simple addition again, but nothing came of
> it.

This isn't about an addition, netdev_priv() is still there. The
semantics silently changed, that's it.

I'm fine with its removal, is it ok? The trivial "return dev->priv"
isn't worth it anyway.
-- 
Krzysztof Halasa
