From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: Fwd: Re: Section 4 No. 9,10 Failed was occurred by IPv6 Ready
 Logo Conformance Test
Date: Fri, 15 Apr 2016 15:59:35 +0200 (CEST)
Message-ID: <293867211.2746.1460728775752@office.mailbox.org>
References: <57020D23.9010403@jp.fujitsu.com>
 <5710AAA3.2020703@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: hannes@stressinduktion.org, rongqing.li@windriver.com,
	netdev@vger.kernel.org, Yuki Machida <machida.yuki@jp.fujitsu.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mailbox.org ([80.241.60.215]:40258 "EHLO mx2.mailbox.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703AbcDON7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2016 09:59:40 -0400
In-Reply-To: <5710AAA3.2020703@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On April 15, 2016 at 10:47 AM Yuki Machida <machida.yuki@jp.fujitsu.com> wrote:
> 
> >> commit 9d289715eb5c252ae15bd547cb252ca547a3c4f2
> >> Author: Hagen Paul Pfeifer <hagen@jauu.net>
> >> Date: Thu Jan 15 22:34:25 2015 +0100
> >>
> >>       ipv6: stop sending PTB packets for MTU < 1280
> >>
> >>       Reduce the attack vector and stop generating IPv6 Fragment Header for
> >>       paths with an MTU smaller than the minimum required IPv6 MTU
> >>       size (1280 byte) - called atomic fragments.
> >>
> >>       See IETF I-D "Deprecating the Generation of IPv6 Atomic Fragments" [1]
> >>       for more information and how this "feature" can be misused.
> >>
> >>       [1]
> >> https://tools.ietf.org/html/draft-ietf-6man-deprecate-atomfrag-generation-00
> >>
> >>       Signed-off-by: Fernando Gont <fgont@si6networks.com>
> >>       Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> >>       Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >>       Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > I will try.
> 
> I confirmed that v4.1.20 revert above patch is passed Section 4 No. 9 and 10 testcases
> in IPv6 Ready Logo Conformance Test.
> I can't immediately revert above patch from v4.6-rc1 by implementation has changed.

is it to please a conforming test tool or fix "revert 9d289715eb5c2" a real problem? If so: which problem do you have with 9d289715eb5c2 or draft-ietf-6man-deprecate-atomfrag-generation-06?


Hagen
