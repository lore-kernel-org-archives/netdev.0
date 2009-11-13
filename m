From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [net-next-2.6 PATCH v6 5/7 RFC] TCPCT part 1e: implement socket option TCP_COOKIE_TRANSACTIONS
Date: Fri, 13 Nov 2009 15:11:00 +0100
Message-ID: <87bpj6tszv.fsf@basil.nowhere.org>
References: <4AFCDA9E.8050003@gmail.com> <4AFCEA59.3060707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46550 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312AbZKMOK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 09:10:57 -0500
In-Reply-To: <4AFCEA59.3060707@gmail.com> (William Allen Simpson's message of "Fri, 13 Nov 2009 00:10:49 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson <william.allen.simpson@gmail.com> writes:

> This is a straightforward re-implementation of an earlier (year-old)
> patch that no longer applies cleanly, with permission of the original
> author (Adam Langley):
>
>    http://thread.gmane.org/gmane.linux.network/102586
>
> The principle difference is using a TCP option to carry the cookie nonce,
> instead of a user configured offset in the data.
>
> Allocations have been rearranged to avoid requiring GFP_ATOMIC.
>
> Requires:
>   net: TCP_MSS_DEFAULT, TCP_MSS_DESIRED
>   TCPCT part 1c: sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS
>   TCPCT part 1d: define TCP cookie option, extend existing struct's

BTW if you add new socket options you should always submit a manpage
patch to linux-man@vger.kernel.org too

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
