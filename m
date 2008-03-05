From: David Miller <davem@davemloft.net>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Tue, 04 Mar 2008 16:10:03 -0800 (PST)
Message-ID: <20080304.161003.129716254.davem@davemloft.net>
References: <20080303201701.GF8974@wotan.suse.de>
	<Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com>
	<20080305000637.GA1510@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clameter@sgi.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yanmin_zhang@linux.intel.com,
	dada1@cosmosbay.com
To: npiggin@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56015
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756551AbYCEAKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 19:10:04 -0500
In-Reply-To: <20080305000637.GA1510@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Piggin <npiggin@suse.de>
Date: Wed, 5 Mar 2008 01:06:37 +0100

> On Mon, Mar 03, 2008 at 01:16:44PM -0800, Christoph Lameter wrote:
> > On Mon, 3 Mar 2008, Nick Piggin wrote:
> > 
> > > > HWCACHE_ALIGN means that you want the object to be aligned at 
> > > > cacheline boundaries for optimization. Why does crossing cacheline 
> > > > boundaries matter in this case?
> > > 
> > > No, HWCACHE_ALIGN means that you want the object not to cross cacheline
> > > boundaries for at least cache_line_size() bytes. You invented new
> > 
> > Interesting new definition....
> 
> Huh?? It is not a new definition, it is exactly what SLAB does. And
> then you go and do something different and claim that you follow
> what slab does.

I completely agree with Nick.
