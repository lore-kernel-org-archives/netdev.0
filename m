From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH 0/3 net-next RFC] selftest: Introduce test abstraction
 for net
Date: Tue, 09 Apr 2013 13:22:45 +0200
Message-ID: <5163FA05.5040301@redhat.com>
References: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, willemb@google.com,
	edumazet@google.com, Daniel Baluta <dbaluta@ixiacom.com>
To: Alexandru Copot <alex.mihai.c@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759513Ab3DILW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 07:22:56 -0400
In-Reply-To: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2013 12:30 PM, Alexandru Copot wrote:
> This series adds a generic test abstraction that can make
> writing testcases easier. A generic_test structure is
> used to define a test and its methods.

Probably it would make sense as well to include other subsystem
test case developers/authors from testing/selftests/* in discussion,
since not only testing/selftests/net/ might want to use it, not
sure.

I don't know how far we want to go here or what is planned, but
maybe also having a look at libtap or others might be quite useful:

   https://github.com/zorgnax/libtap/blob/master/tap.h
   https://github.com/zorgnax/libtap/blob/master/tap.c

If we want to introduce something generic, then this should maybe
go under testing/selftests/lib/ so that others can make use of
that as well and convert (at least) some of their selftests.

> The second patch updates the socket tests to use the
> new framework, and the third patch creates new tests
> for [set/get]sockopt with some IPV6_* options.
>
> Signed-of by Alexandru Copot <alex.mihai.c@gmail.com>
> Cc: Daniel Baluta <dbaluta@ixiacom.com>
