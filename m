From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IPv6 path MTU discovery broken
Date: Sat, 28 Sep 2013 22:51:31 +0200
Message-ID: <20130928205131.GB20124@sesse.net>
References: <20130927201420.GB12043@sesse.net>
 <20130928203318.GC23654@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:56544 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755070Ab3I1Uvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 16:51:37 -0400
Content-Disposition: inline
In-Reply-To: <20130928203318.GC23654@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 28, 2013 at 10:33:18PM +0200, Hannes Frederic Sowa wrote:
>> Could this be related somehow to the packets coming from 2001:67c:29=
f4::31,
>> while the default route is to a link-local address? (An RPF issue?) =
This used
>> to work (although it was often flaky for me) in 3.10 and before. I c=
an't
>> easily bisect, though, as I don't boot this machine too often.
> This looks like a bug and should definitely get fixed. There should b=
e
> no RPF issue. May I have a look at your /proc/net/ipv6_route?

Hi,

I removed all the =E2=80=9Cweird=E2=80=9D routes, and confirmed it fixe=
d the problem.
However, upon adding them back again, the problem was still gone
(despite flushing the route cache).

This means that the issue has gone back to being intermittent, which is=
 of
course the worst kind of bug to trace down. :-) I'll dump
/proc/net/ipv6_route and send you once I see the bug manifest itself ag=
ain,
OK?

/* Steinar */
--=20
Homepage: http://www.sesse.net/
