From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Sat, 23 Oct 2010 21:37:00 +0400
Message-ID: <239681287855420@web159.yandex.ru>
References: <loom.20101012T185411-307@post.gmane.org>
	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>
	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>
	 <1287805487.2658.5.camel@edumazet-laptop>
	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net> <1287851745.2658.364.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward15.mail.yandex.net ([95.108.130.119]:45071 "EHLO
	forward15.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898Ab0JWRnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Oct 2010 13:43:07 -0400
In-Reply-To: <1287851745.2658.364.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

23.10.2010, 20:36, "Eric Dumazet" <eric.dumazet@gmail.com>:

> With a normal workload, on a dual cpu machine, a missing memory barrier
> can stay un-noticed for quite a long time. The race window is so small
> that probability for the bug might be 0.0000001 % or something like
> that :(

Eric, I'd like to remind you that I've faced the similar problem on simple x86.

See http://kerneltrap.org/mailarchive/linux-netdev/2010/3/9/6271568

Two main differences for our case:

1) There is no userspace workload (except for bgpd), no changes in interfaces
2) We are not using multiple routing tables

This panic was pretty rare in our case  (not more that 2 times per month).

Currently we're running fine with disabled CONFIG_IP_MULTIPLE_TABLES.

-- 
wbr, Oleg.
