From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/5] sctp: use transport hashtable to replace
 association's with rhashtable
Date: Wed, 30 Dec 2015 16:57:23 -0500
Message-ID: <1451512643.8255.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1451495979.8255.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151230173202.GB16270@localhost.localdomain>
	 <1451502680.8255.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151230.154425.1221426772185302815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: marcelo.leitner@gmail.com, lucien.xin@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	mleitner@redhat.com, vyasevic@redhat.com, daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34232 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754012AbbL3V5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 16:57:25 -0500
In-Reply-To: <20151230.154425.1221426772185302815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-30 at 15:44 -0500, David Miller wrote:

> It is more fun than waiting longer for the more limited uses of it to
> trigger problems.
> 
> I cannot be convinced that using it in more places in order to find
> and fix more bugs is a bad thing.
> 
> I'm sorry if a lot of bug fixes in a short period of time concerns
> you, but for me that's an even clearer sign that it needs help, and
> exposing it to more use cases is one of the best forms of help it can
> get.
> 
> It also tells me that the people actually working on those fixes, such
> as Herbert Xu, are motivated and reliable when they are shown properly
> formed bug reports.
> 
> I cannot think of a report Herbert and others did not resolve in a
> timely manner.  They usually add test cases too.


I have no doubts we can fix bugs in upstream kernels in a few days (at
most).

The problem is when a customer is stuck using a distro, with a release
cycle of extra months after upstream fixes.

I had to deal with customers having issues with resolvers hitting the
netlink/rhashtable bugs, and I can tell you it was not pretty nor funny.

Seeing all these SCTP bugs being currently tracked/fixed (reports from
Dmitry Vyukov), I am concerned about having to backport fixes into old
kernels without proper rhashtable if now SCTP relies heavily on
rhashtable.

Hopefully nothing bad will happen.
