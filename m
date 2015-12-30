From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] sctp: use transport hashtable to replace
 association's with rhashtable
Date: Wed, 30 Dec 2015 15:44:25 -0500 (EST)
Message-ID: <20151230.154425.1221426772185302815.davem@davemloft.net>
References: <1451495979.8255.32.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151230173202.GB16270@localhost.localdomain>
	<1451502680.8255.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo.leitner@gmail.com, lucien.xin@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	mleitner@redhat.com, vyasevic@redhat.com, daniel@iogearbox.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476AbbL3Uo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 15:44:27 -0500
In-Reply-To: <1451502680.8255.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Dec 2015 14:11:20 -0500

> Let see how funny it will be then.

It is more fun than waiting longer for the more limited uses of it to
trigger problems.

I cannot be convinced that using it in more places in order to find
and fix more bugs is a bad thing.

I'm sorry if a lot of bug fixes in a short period of time concerns
you, but for me that's an even clearer sign that it needs help, and
exposing it to more use cases is one of the best forms of help it can
get.

It also tells me that the people actually working on those fixes, such
as Herbert Xu, are motivated and reliable when they are shown properly
formed bug reports.

I cannot think of a report Herbert and others did not resolve in a
timely manner.  They usually add test cases too.

And that matters more to me than anything else.  A subsystem can be
buggy as shit, but if someone is responsible about fixing the reported
bugs properly, then I have absolutely nothing to worry about.
