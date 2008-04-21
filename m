From: gerrit@erg.abdn.ac.uk
Subject: Re: [PATCH] [DCCP]: Convert do_gettimeofday() to getnstimeofday().
Date: Mon, 21 Apr 2008 15:03:50 +0100 (BST)
Message-ID: <1538.84.55.217.198.1208786630.squirrel@84.55.217.198>
References: <20080421.162227.63020853.yoshfuji@linux-ipv6.org>
    <20080421.023503.242108516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	dccp@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:52704 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754798AbYDUOEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 10:04:01 -0400
In-Reply-To: <20080421.023503.242108516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Mon, 21 Apr 2008 16:22:27 +0900 (JST)
>
>> What do_gettimeofday() does is to call getnstimeofday() and
>> to convert the result from timespec{} to timeval{}.
>> We do not always need timeval{} and we can convert timespec{}
>> when we really need (to print).
>>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>
> This looks good too, but I'll be polite and wait for any
> DCCP maintainer ACKs :-)
>
This mirrors a patch which is currently in the test tree and does the
update to timespec, apart from a few other changes. It is a good idea,
since that in turn mirrors tcp_probe.c
Hope Arnado will in some future have time to look at some of the test tree
patches, in any case this patch does not harm.



The University of Aberdeen is a charity registered in Scotland, No SC013683.

