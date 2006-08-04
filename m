From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: problems with e1000 and jumboframes
Date: Fri, 4 Aug 2006 23:42:11 +0400
Message-ID: <20060804194209.GA25167@2ka.mipt.ru>
References: <41b516cb0608031334s6e159e99tb749240f44ae608d@mail.gmail.com> <E1G8sif-0003oY-00@gondolin.me.apana.org.au> <20060804061513.GB413@2ka.mipt.ru> <41b516cb0608040834o1d433f23v2f2ba1a1b05ccbc6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Herbert Xu <herbert@gondor.apana.org.au>, arnd@arndnet.de,
	olel@ans.pl, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56737 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932605AbWHDTmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 15:42:44 -0400
To: Chris Leech <chris.leech@gmail.com>
Content-Disposition: inline
In-Reply-To: <41b516cb0608040834o1d433f23v2f2ba1a1b05ccbc6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 08:34:46AM -0700, Chris Leech (chris.leech@gmail.com) wrote:
> So how many skb allocation schemes do you code into a single driver?
> Kmalloc everything, page alloc everything, combination of kmalloc and
> page buffers for hardware that does header split?  That's three
> versions of the drivers receive processing and skb allocation that
> need to be maintained.

At least try to create scheme which will not end up in 32k allocation in
atomic context. Generally I would recommend to use frag_list as much as
possible (or you can reuse skb list).
 
> - Chris

-- 
	Evgeniy Polyakov
