From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] genetlink: make netns aware
Date: Wed, 17 Jun 2009 14:19:01 -0700
Message-ID: <m18wjqwoca.fsf@fess.ebiederm.org>
References: <1245267218.31588.41.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47532 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340AbZFQVTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 17:19:04 -0400
In-Reply-To: <1245267218.31588.41.camel@johannes.local> (Johannes Berg's message of "Wed\, 17 Jun 2009 21\:33\:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> This makes generic netlink network namespace aware.
> No actual generic netlink families are made namespace
> aware, they need to be checked one by one and then
> set the family->netnsok member to true.

Nothing at first glance looks wrong.

Most of these genetlink things are network related so making it
network namespace aware makes sense.

My impression had been that genetlink was mostly not network related
and I would have to solve the other hard problem of how to filter
sockets based on other namespaces.  I guess that can be delayed for
a while longer.

Eric
