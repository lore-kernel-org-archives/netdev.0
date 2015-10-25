From: Masashi Honma <masashi.honma@gmail.com>
Subject: Re: [PATCH] ipv6 route: Aggregate table getting code
Date: Sun, 25 Oct 2015 11:42:19 +0900
Message-ID: <562C418B.9050909@gmail.com>
References: <1445129499-2496-1-git-send-email-masashi.honma@gmail.com>
 <20151018.230913.533343373986091178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35772 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbbJYCmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 22:42:23 -0400
Received: by pasz6 with SMTP id z6so152791963pas.2
        for <netdev@vger.kernel.org>; Sat, 24 Oct 2015 19:42:22 -0700 (PDT)
In-Reply-To: <20151018.230913.533343373986091178.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/10/19 15:09, David Miller wrote:
> This is not correct.
>
> The whole point of the test is so that the kernel log message
> warning for failing to provide NLM_F_CREATE can be printed
> in precisely the correct conditions.

Thanks. Now I understand importance of the warning.

Though fib6_get_table() is called twice to show the warning.
So I made another patch to reduce calling the function.
