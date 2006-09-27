From: Patrick McHardy <kaber@trash.net>
Subject: Re: tc related lockdep warning.
Date: Wed, 27 Sep 2006 11:57:44 +0200
Message-ID: <451A4B18.1010809@trash.net>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2> <4517D9A6.70307@trash.net> <45195219.7050105@trash.net> <20060926212034.GA3134@redhat.com> <20060927085427.GA1619@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:11190 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965491AbWI0J5r
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 05:57:47 -0400
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20060927085427.GA1619@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> Sorry for my not humble and simplistic opinion, but I'd dare
> to remind you are changing "stable" version and even without
> this lockups this patch would look very "serious". Why don't
> try to restore not-rcu version of qdisc_destroy which looks
> not lot to do.

I'm trying to restore the original rules, while keeping the
loopback optimization. That should be safe once I figure out
whats causing the crash.
