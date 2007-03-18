From: Andi Kleen <ak@muc.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: 18 Mar 2007 13:08:14 +0100
Message-ID: <20070318120814.GA45869@muc.de>
References: <20070316.023331.59468179.davem@davemloft.net> <45FB005D.9060809@goop.org> <1174127638.8897.75.camel@localhost.localdomain> <20070318.003309.71088169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, jeremy@goop.org, mingo@elte.hu,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, xen-devel@lists.xensource.com,
	chrisw@sous-sol.org, zach@vmware.com, anthony@codemonkey.ws,
	torvalds@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colin.muc.de ([193.149.48.1]:3979 "EHLO mail.muc.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209AbXCRMIR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2007 08:08:17 -0400
Date: Sun, 18 Mar 2007 13:08:14 +0100
Content-Disposition: inline
In-Reply-To: <20070318.003309.71088169.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The idea is _NOT_ that you go look for references to the paravirt_ops
> members structure, that would be stupid and you wouldn't be able to
> use the most efficient addressing mode on a given cpu, you'd be
> patching up indirect calls and crap like that.  Just say no...

That wouldn't handle inlines though. At least some of the current
paravirtops like cli/sti are critical enough to require inlining.

-Andi
