From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPv6: optionaly validate RAs on raw sockets
Date: Wed, 11 Jul 2007 09:10:59 -0700
Message-ID: <OF12E7973A.D9D0F9C5-ON88257315.005882D0-88257315.0058D5B9@us.ibm.com>
References: <4694E4C4.6010404@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	=?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>,
	=?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:59753 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194AbXGKQLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 12:11:08 -0400
In-Reply-To: <4694E4C4.6010404@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Since you asked for another idea, how about using netlink to send 
_validated_ RA
> information to interested parties?
> 
> -vlad

        That sounds like a good idea to me (FWIW),
though I also still think a simple raw-socket
application would do it just fine, possibly with
no kernel modification at all.
        But since the kernel wouldn't be maintaining
the DNS info, which was my real objection to the
original version,  netlink would work well too.

                                                +-DLS

