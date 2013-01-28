From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] SCTP: Free the per-net sysctl table on net exit. v2
Date: Mon, 28 Jan 2013 07:47:12 -0800
Message-ID: <877gmxtim7.fsf@xmission.com>
References: <20130127.193511.2294954038548420781.davem@davemloft.net>
	<87libe3w69.fsf@xmission.com> <87obgayoo8.fsf_-_@xmission.com>
	<20130128.001125.1697434398997976656.davem@davemloft.net>
	<510637D8.9000305@fold.natur.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, vyasevich@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37606 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757Ab3A1Pr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 10:47:26 -0500
In-Reply-To: <510637D8.9000305@fold.natur.cuni.cz> (Martin Mokrejs's message
	of "Mon, 28 Jan 2013 09:33:28 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Mokrejs <mmokrejs@fold.natur.cuni.cz> writes:

> David Miller wrote:
>> From: ebiederm@xmission.com (Eric W. Biederman)
>> Date: Sun, 27 Jan 2013 19:25:11 -0800
>> 
>>> The typo is fixed in the patch this time in addition to my test
>>> tree.
>> 
>> Applied, thanks for fixing this up Eric.
>
> I did check now how come that I patched my 3.7.4 on Jan 24. Looks like
> -head or -next has different namings. For me, the original patch applied
> fine. So far I haven't hit the memleak although it happened only once to me
> before the patch.

The problem isn't that the patch doesn't apply the problem is that the
patch did not build.  The naming has not changed in the git history.

> But probably I can confirm say Tested-by:.
>
> #
> -rw-r--r-- 1 root root  8435 Jan 24 17:12 /usr/src/linux-3.7.4/net/sctp/sysctl.c
> -rw-rw-r-- 1 root root  8347 Jan 21 20:45 /usr/src/linux-3.7.4/net/sctp/sysctl.c.orig
> # ls -la /usr/src/linux-3.7.4/net/sctp/sysctl.o
> -rw-r--r-- 1 root root 246144 Jan 21 22:37 /usr/src/linux-3.7.4/net/sctp/sysctl.o
> # ls -la /usr/src/linux-3.7.4/arch/x86/boot/bzImage 
> -rw-r--r-- 1 root root 3794592 Jan 21 22:45 /usr/src/linux-3.7.4/arch/x86/boot/bzImage
> #

It doesn't look look like you rebuilt anything after you applied the
changes to net/sctp/sysctl.c.  sysctl.o and bzImage are both 3 days older.

Eric
