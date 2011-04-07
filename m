From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: problem of "ipv4: revert Set rt->rt_iif more sanely on output routes."
Date: Thu, 07 Apr 2011 16:19:24 +0900
Message-ID: <877hb6sf43.fsf@devron.myhome.or.jp>
References: <20110406.132829.116375350.davem@davemloft.net>
	<87ipuqsmwl.fsf@devron.myhome.or.jp>
	<20110406.223400.71127145.davem@davemloft.net>
	<20110406.224244.104071339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.co.jp ([210.171.160.6]:57223 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752573Ab1DGHT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 03:19:28 -0400
In-Reply-To: <20110406.224244.104071339.davem@davemloft.net> (David Miller's
	message of "Wed, 06 Apr 2011 22:42:44 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> So fix is something like:
>
> 1) Add "int rt_route_iif;" to struct rtable
>
> 2) For input routes, always set rt_route_iif to same value as rt_iif
>
> 3) For output routes, always set rt_route_iif to zero.  Set rt_iif
>    as it is done currently.
>
> 4) Change rt_is_{output,input}_route() to test rt_route_iif
>
> This should fix the bug and not introduce new regressions.
>
> Can you write and test such a patch with your test case?

Ok. I'll try, but I'm not sure I understand the above correctly. Well,
I'll send the patch after testing.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
