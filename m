From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 08/29] mm: kmem_cache_objs_to_pages()
Date: Wed, 21 Feb 2007 17:47:59 +0200
Message-ID: <84144f020702210747t50d7d92ei1a2f5da8bf117d40@mail.gmail.com>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
	 <20070221144842.299190000@taijtu.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Thomas Graf" <tgraf@suug.ch>, "David Miller" <davem@davemloft.net>
To: "Peter Zijlstra" <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:33725 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161299AbXBUPsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 10:48:01 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1070196uga
        for <netdev@vger.kernel.org>; Wed, 21 Feb 2007 07:48:00 -0800 (PST)
In-Reply-To: <20070221144842.299190000@taijtu.programming.kicks-ass.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peter,

On 2/21/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> Provide a method to calculate the number of pages needed to store a given
> number of slab objects (upper bound when considering possible partial and
> free slabs).

So how does this work? You ask the slab allocator how many pages you
need for a given number of objects and then those pages are available
to it via the page allocator? Can other users also dip into those
reserves?

I would prefer we simply have an API for telling the slab allocator to
keep certain number of pages in a reserve for a cache rather than
exposing internals such as object size to rest of the world.

                                 Pekka
