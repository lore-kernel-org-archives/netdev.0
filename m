From: Tore Anderson <tore@linpro.no>
Subject: Re: [PATCH] Improve cached ECMP documentation
Date: Wed, 07 Mar 2007 15:17:04 +0100
Message-ID: <45EEC960.5000105@linpro.no>
References: <20070307073932.GA1675@ff.dom.local> <45EEB218.8000804@linpro.no> <20070307135415.GB2268@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.linpro.no ([213.236.139.167]:38839 "EHLO
	mailhub.linpro.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965512AbXCGORF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 09:17:05 -0500
In-Reply-To: <20070307135415.GB2268@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jarek Poplawski

> I don't feel bothered at all. Your letter could
> make an impression there is a lack of help and
> google not working, but it's not always true. 
> So, sometimes people probably wait to see, they
> will only help and not do all your work.

   Of course.  I tried hard to figure it out on my own, but couldn't.
  I'm sorry if I was unable to communicate that properly - I never would
  ask someone for help without having attempted to figure it out on my
  own first.

> Without this there is a possibility the route could be
> changed during connection.

   That's no problem, it could be changed between each packet for all I
  care.  Connections are a TCP concept, and routers normally only care
  about IPs.  The routes change all the time anyway, multipath or not.
  I'm quite certain I get way more than one BGP update per second in a
  normal day at least.

   So what I'm trying to achieve is only to better balance outgoing
  traffic between two transit links to avoid saturating the physical
  layer on one of the links.  My multipath route achieves this nicely
  when CONFIG_IP_ROUTE_MULTIPATH_CACHED is unset - thanks again!  It
  behaved just like a normal singlepath route when it was enabled though
  (even with no multipath modules loaded) - not quite what I expected.

Regards
-- 
Tore Anderson
