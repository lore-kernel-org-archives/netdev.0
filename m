From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] ipv6: Fix possible NULL dereference in icmp6_dst_alloc
Date: Wed, 27 Jan 2010 10:34:17 +0000
Message-ID: <20100127103417.GA15206@ff.dom.local>
References: <20100126094817.GA7780@ff.dom.local> <20100126103524.GB7780@ff.dom.local> <20100127095952.GA11635@ff.dom.local> <20100127.021424.263649631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, djohnson@starentnetworks.com,
	sakkiped@starentnetworks.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:52075 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab0A0KeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 05:34:23 -0500
Received: by fxm20 with SMTP id 20so1388046fxm.21
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 02:34:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100127.021424.263649631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2010 at 02:14:24AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 27 Jan 2010 09:59:52 +0000
> 
> > While looking at the "Deadlock in IPv6 code while garbage collection
> > on the rwlock protecting the routing tree" reported by Srinivas
> > Akkipeddi I found there is possible a NULL pointer dereference in
> > icmp6_dst_alloc().
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Jarek, if rt is NULL so is &rt->u.dst
> 
> That's two patches trying to fix this same non-problem in
> two different places today :-)

Yes, great joke! :-\

(Btw, maybe it's a sign this might be more readable?)

Thanks,
Jarek P.
