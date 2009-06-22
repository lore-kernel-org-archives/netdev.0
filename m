From: David Miller <davem@davemloft.net>
Subject: Re: velocity driver unmaps incorrect size.
Date: Sun, 21 Jun 2009 19:42:48 -0700 (PDT)
Message-ID: <20090621.194248.72335974.davem@davemloft.net>
References: <20090621173745.GC26093@redhat.com>
	<20090621.184345.194558005.davem@davemloft.net>
	<20090622024044.GA3157@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38205
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753386AbZFVCmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2009 22:42:44 -0400
In-Reply-To: <20090622024044.GA3157@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Sun, 21 Jun 2009 22:40:44 -0400

> On Sun, Jun 21, 2009 at 06:43:45PM -0700, David Miller wrote:
> 
>  > Is it possible that for some reason
>  > your build is forcing VELOCITY_ZERO_COPY_SUPPORT to be defined
>  > for some reason?
> 
> Memory corruption maybe?
> It's especially odd in that it only happens once during boot,
> and never happens again. This is my firewall/router, so there's
> more packets going through that box than any other I have.

I would not be inclined to this theory.  Regardless of what garbage is
read from skb->len, it's always going to be at least ETH_ZLEN due to
the "max of skb->len and ETH_ZLEN" assignment there.

> btw, given the zerocopy stuff has been disabled for so long,
> is it worth keeping it ?

I'm pretty sure it should be tossed.  I wonder if anyone even tries
to build that code these days.
