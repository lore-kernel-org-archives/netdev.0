From: jamal <hadi@cyberus.ca>
Subject: Re: HTB/HSFC shaping precision
Date: Wed, 21 Nov 2007 10:06:47 -0500
Message-ID: <1195657607.4437.8.camel@localhost>
References: <20071120211258.M55249@visp.net.lb>
	 <20071121094710.GA2295@ff.dom.local>  <20071121103024.M12218@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:39026 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561AbXKUPG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 10:06:58 -0500
Received: by py-out-1112.google.com with SMTP id u77so7248376pyb
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2007 07:06:57 -0800 (PST)
In-Reply-To: <20071121103024.M12218@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-21-11 at 12:31 +0200, Denys Fedoryshchenko wrote:
> On Wed, 21 Nov 2007 10:47:10 +0100, Jarek Poplawski wrote
> > 
> > But, if you have full control on your side, it looks like a kind of
> > realtime traffic, and then HFSC should be more appropriate for this
> > (but I only 'heard' about this).
> 
> One message later, thats what i dreamed about :-)
> Subject: [RFC][PATCH 1/3] NET_SCHED: PSPacer qdisc module 
> On website they have very good explanation... 
> http://www.gridmpi.org/gridtcp.jsp

That looks interesting - without reading the papers a few questions are
developing in my brain cells; for example it looks very similar to what
the chelsio NICs claim to do (which could be a good thing for TCP).
Whenever i see someone implementing something in hardware, i always get
flushes of "patents". 

Denys, one of the things i have noticed with iperf is it tries to be
clever and "probe" the available bandwidth first. So you may not get the
most optimal use of of your bandwidth. Try something like pktgen, its
quiet accurate in its measurements. Just add a tc drop rule on the
receiver to get the accounting.

cheers,
jamal

