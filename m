From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Thu, 6 Mar 2008 14:56:42 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803061453360.16212@schroedinger.engr.sgi.com>
References: <20080303201701.GF8974@wotan.suse.de>
 <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com>
 <20080305000637.GA1510@wotan.suse.de> <20080304.161003.129716254.davem@davemloft.net>
 <Pine.LNX.4.64.0803051257030.30742@schroedinger.engr.sgi.com>
 <20080306025758.GB27150@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yanmin_zhang@linux.intel.com,
	dada1@cosmosbay.com
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:32817 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753932AbYCFW47 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 17:56:59 -0500
In-Reply-To: <20080306025758.GB27150@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Mar 2008, Nick Piggin wrote:

> There looks like definitely some networking slabs that pass the flag
> and can be non-power-of-2. And don't forget cachelines can be anywhere
> up to 256 bytes in size. So yeah it definitely makes sense to merge
> the patch and then examine the callers if you feel strongly about it.

Just do not like to add fluff that has basically no effect. I just tried 
to improve things by not doing anything special if we cannot cacheline 
align object. Least surprise (at least for me). It is bad enough that we 
just decide to ignore the request for alignment for small caches.




