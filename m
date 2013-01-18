From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net] ipv6: Fix addrconf_dst_alloc() failure check.
Date: Fri, 18 Jan 2013 23:38:39 +0900
Message-ID: <50F95E6F.7050807@linux-ipv6.org>
References: <50F93879.6010201@linux-ipv6.org> <1358519314.11051.111.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45764 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755196Ab3AROik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 09:38:40 -0500
In-Reply-To: <1358519314.11051.111.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> On Fri, 2013-01-18 at 20:56 +0900, YOSHIFUJI Hideaki wrote:
>> The function returns NULL on error and it never return error code
>> embedded in pointer.
>>
> 
> Which functions returns NULL ?
> 
> addrconf_dst_alloc() returns ERR_PTR(-ENOMEM) in case of error in my net
> tree.
> 
> Also, please consider adding the bug origin in your changelogs.

Oh, right.  I probably looked into different dst_alloc variants
and was confused.  Please ignore.

--yoshfuji
