From: Andi Kleen <ak@muc.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: 18 Mar 2007 18:04:14 +0100
Message-ID: <20070318170414.GB45869@muc.de>
References: <20070316.023331.59468179.davem@davemloft.net> <45FB005D.9060809@goop.org> <1174127638.8897.75.camel@localhost.localdomain> <20070318.003309.71088169.davem@davemloft.net> <20070318120814.GA45869@muc.de> <45FD619D.6030402@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rusty@rustcorp.com.au,
	mingo@elte.hu, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, chrisw@sous-sol.org,
	zach@vmware.com, anthony@codemonkey.ws,
	torvalds@linux-foundation.org, netdev@vger.kernel.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colin.muc.de ([193.149.48.1]:1439 "EHLO mail.muc.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753256AbXCRREQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2007 13:04:16 -0400
Date: Sun, 18 Mar 2007 18:04:14 +0100
Content-Disposition: inline
In-Reply-To: <45FD619D.6030402@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The bigger problem is that you don't know what registers you can
> clobber.  For the pv_ops in hand-written asm, that a big pain.  The code
> either has to assume the worst, or the "relocator" has to do something
> more sophisticated (like look for push/pop pairs surrounding the call,
> perhaps?).

You could use the dwarf2 unwind tables. They have exact information
what register has what. But it would likely get complicated.

-Andi
