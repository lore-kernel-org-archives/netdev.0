From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: updates to syncookies - timestamps not needed any more (freebsd)
Date: Mon, 8 Jul 2013 20:09:02 +0200
Message-ID: <20130708180902.GB9763@order.stressinduktion.org>
References: <20130708160421.GA9763@order.stressinduktion.org> <1373301578.4979.115.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:32939 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528Ab3GHSJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 14:09:04 -0400
Content-Disposition: inline
In-Reply-To: <1373301578.4979.115.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 08, 2013 at 09:39:38AM -0700, Eric Dumazet wrote:
> On Mon, 2013-07-08 at 18:04 +0200, Hannes Frederic Sowa wrote:
> > Interesting patch by Andre Opperann of FreeBSD:
> > <http://lists.freebsd.org/pipermail/freebsd-net/2013-July/035999.html>
> > 
> > Greetings,
> 
> 
> Switching from SHA to SipHash would be nice, if SipHash is secure
> enough.
> 
> (We do not use MD5 but SHA for syncookies)

Blake2[0] came to my mind when I read this. It is by one of the same authors
as SipHash.

[0] https://blake2.net/

Greetings,

  Hannes
