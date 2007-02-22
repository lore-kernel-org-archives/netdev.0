From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 08/29] mm: kmem_cache_objs_to_pages()
Date: Thu, 22 Feb 2007 11:49:16 +0200
Message-ID: <84144f020702220149m21543847ge6af27e0468a5c86@mail.gmail.com>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
	 <20070221144842.299190000@taijtu.programming.kicks-ass.net>
	 <84144f020702210747t50d7d92ei1a2f5da8bf117d40@mail.gmail.com>
	 <1172136508.6374.41.camel@twins>
	 <84144f020702220145h4f670ec6g428dc046ee9dcc71@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Thomas Graf" <tgraf@suug.ch>, "David Miller" <davem@davemloft.net>
To: "Peter Zijlstra" <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:57224 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567AbXBVJtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 04:49:18 -0500
Received: by ug-out-1314.google.com with SMTP id 44so66207uga
        for <netdev@vger.kernel.org>; Thu, 22 Feb 2007 01:49:18 -0800 (PST)
In-Reply-To: <84144f020702220145h4f670ec6g428dc046ee9dcc71@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/22/07, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> So you are only interested in rough estimation of how much many pages
> you need for a given amount of objects? Why not use ksize() for that
> then?

Uhm, I obviously meant, why not expose obj_size() instead.
