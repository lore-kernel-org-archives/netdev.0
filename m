From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Poor TCP bandwidth between network namespaces
Date: Fri, 08 Feb 2013 17:33:38 -0800
Message-ID: <1360373618.6696.2.camel@edumazet-glaptop>
References: <20130204144320.GG1353@tostaky>
	 <20130204225227.GC6898@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Emmanuel Jeanvoine <emmanuel.jeanvoine@inria.fr>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:55392 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758593Ab3BIBdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 20:33:42 -0500
Received: by mail-pa0-f47.google.com with SMTP id bj3so2325265pad.20
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 17:33:41 -0800 (PST)
In-Reply-To: <20130204225227.GC6898@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-04 at 23:52 +0100, Hannes Frederic Sowa wrote:
> On Mon, Feb 04, 2013 at 03:43:20PM +0100, Emmanuel Jeanvoine wrote:
> > I'm wondering why the overhead is so high when performing TCP 
> > transfers between two network namespaces. Do you have any idea about 
> > this issue? And possibly, how to increase the bandwidth (without 
> > modifying the MTU on the veths) between network namespaces?
> 
> You could try Eric's patch (already in net-next) and have a look at the rest
> of the discussion:
> 
> http://article.gmane.org/gmane.linux.network/253589

Another thing to consider is the default MTU value :

65536 for lo, and 1500 for veth

It easily explains half performance for veth

One another thing is the tx-nocache-copy setting, this can explain some
extra percents.
