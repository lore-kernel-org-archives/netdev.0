From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] ipv4: Disallow non-namespace aware protocols to register.
Date: Thu, 14 Feb 2013 22:25:26 -0800
Message-ID: <87pq028561.fsf@xmission.com>
References: <20130205.144302.2065386693901345213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39421 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335Ab3BOGZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 01:25:33 -0500
In-Reply-To: <20130205.144302.2065386693901345213.davem@davemloft.net> (David
	Miller's message of "Tue, 05 Feb 2013 14:43:02 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> All in-tree ipv4 protocol implementations are now namespace
> aware.  Therefore all the run-time checks are superfluous.
>
> Reject registry of any non-namespace aware ipv4 protocol.
> Eventually we'll remove prot->netns_ok and this registry
> time check as well.

It has been a long time coming but this is very cool to see we have
finally made all of ipv4 network namespace aware.

Eric
