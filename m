From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] ipv6: fix a potential NULL deref
Date: Mon, 29 Oct 2012 08:05:34 +0100
Message-ID: <1351494334.7394.64.camel@edumazet-glaptop>
References: <1351482620-11008-1-git-send-email-amwang@redhat.com>
	 <1351491005.7394.7.camel@edumazet-glaptop>  <1351493366.8221.2.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:46999 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106Ab2J2HFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 03:05:39 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1909181eek.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 00:05:38 -0700 (PDT)
In-Reply-To: <1351493366.8221.2.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-29 at 14:49 +0800, Cong Wang wrote:
> On Mon, 2012-10-29 at 07:10 +0100, Eric Dumazet wrote:
> > > -		dst_release(&rt->dst);
> > > +		if (rt)
> > > +			dst_release(&rt->dst);
> > >  	}
> > >  
> > 
> > dst_release() is like kfree(), it accepts a NULL argument.
> > 
> 
> 'rt->dst' already dereferences 'rt', no matter dst_release() accepts
> NULL or not.
> 
> 

&rt->dst doesnt dereference rt, you are quite mistaken.

if rt is NULL, &rt->dst is also NULL
