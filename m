From: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>
Subject: Re: [PATCH] SCTP: Free the per-net sysctl table on net exit. v2
Date: Mon, 28 Jan 2013 09:33:28 +0100
Message-ID: <510637D8.9000305@fold.natur.cuni.cz>
References: <20130127.193511.2294954038548420781.davem@davemloft.net> <87libe3w69.fsf@xmission.com> <87obgayoo8.fsf_-_@xmission.com> <20130128.001125.1697434398997976656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fold.natur.cuni.cz ([195.113.57.32]:57819 "HELO
	fold.natur.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753671Ab3A1Idb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 03:33:31 -0500
In-Reply-To: <20130128.001125.1697434398997976656.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Sun, 27 Jan 2013 19:25:11 -0800
> 
>> The typo is fixed in the patch this time in addition to my test
>> tree.
> 
> Applied, thanks for fixing this up Eric.

I did check now how come that I patched my 3.7.4 on Jan 24. Looks like
-head or -next has different namings. For me, the original patch applied
fine. So far I haven't hit the memleak although it happened only once to me
before the patch. But probably I can confirm say Tested-by:.

#
-rw-r--r-- 1 root root  8435 Jan 24 17:12 /usr/src/linux-3.7.4/net/sctp/sysctl.c
-rw-rw-r-- 1 root root  8347 Jan 21 20:45 /usr/src/linux-3.7.4/net/sctp/sysctl.c.orig
# ls -la /usr/src/linux-3.7.4/net/sctp/sysctl.o
-rw-r--r-- 1 root root 246144 Jan 21 22:37 /usr/src/linux-3.7.4/net/sctp/sysctl.o
# ls -la /usr/src/linux-3.7.4/arch/x86/boot/bzImage 
-rw-r--r-- 1 root root 3794592 Jan 21 22:45 /usr/src/linux-3.7.4/arch/x86/boot/bzImage
#

If 3.7 and earlier need the old patch (like I currently think) please make them aware
of that.
Martin
