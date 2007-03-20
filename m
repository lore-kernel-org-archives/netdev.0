From: David Miller <davem@davemloft.net>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
 callsites to make them patchable
Date: Mon, 19 Mar 2007 20:47:12 -0700 (PDT)
Message-ID: <20070319.204712.118947830.davem@davemloft.net>
References: <20070319.120854.30182994.davem@davemloft.net>
	<200703192159.42396.ak@suse.de>
	<Pine.LNX.4.64.0703192015020.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, virtualization@lists.linux-foundation.org,
	jbeulich@novell.com, jeremy@goop.org,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
	virtualization@lists.osdl.org, anthony@codemonkey.ws,
	akpm@linux-foundation.org, mingo@elte.hu
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33634
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933175AbXCTDrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 23:47:13 -0400
In-Reply-To: <Pine.LNX.4.64.0703192015020.6730@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 19 Mar 2007 20:18:14 -0700 (PDT)

> > > Please don't subject us to another couple months of hair-pulling only
> > > to have Linus yank the thing out again, there are certainly more
> > > useful things to spend time on :-)
> 
> Good call. Dwarf2 unwinding simply isn't worth doing. But I won't yank it 
> out, I simply won't merge it. It was more than just totally buggy code, it 
> was an inability of the people to understand that even bugfree code 
> isn't enough - you have to be able to also handle buggy data.

Thank you.
