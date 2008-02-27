From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Wed, 27 Feb 2008 12:24:51 -0800
Message-ID: <20080227122451.6a3b5565.akpm@linux-foundation.org>
References: <47BDBC23.10605@cosmosbay.com>
	<Pine.LNX.4.64.0802271158100.1790@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yanmin_zhang@linux.intel.com, travis@sgi.com
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:47484 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757212AbYB0U0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 15:26:49 -0500
In-Reply-To: <Pine.LNX.4.64.0802271158100.1790@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Feb 2008 11:59:32 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> Any decision made on what to do about this one? Mike or I can 
> repost the per cpu allocator against mm? The fix by Eric could be used 
> in the interim for 2.6.24?
> 

I suppose I'll merge Eric's patch when I've tested it fully (well, as fully
as I test stuff).

It'd be nice to get that cache_line_size()/L1_CACHE_BYTES/L1_CACHE_ALIGN()
mess sorted out.  If it's a mess - I _think_ it is?


