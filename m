From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: do not drop syn_recv on all icmp reports
Date: Tue, 09 Feb 2016 04:17:53 -0500 (EST)
Message-ID: <20160209.041753.1270582307290270805.davem@davemloft.net>
References: <20160203115616.5549851a@samsung9>
	<1454466952.7627.211.camel@edumazet-glaptop2.roam.corp.google.com>
	<1454470272.7627.223.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pety@rusnet.ru
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755734AbcBIJYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 04:24:25 -0500
In-Reply-To: <1454470272.7627.223.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 02 Feb 2016 19:31:12 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Petr Novopashenniy reported that ICMP redirects on SYN_RECV sockets
> were leading to RST.
> 
> This is of course incorrect.
> 
> A specific list of ICMP messages should be able to drop a SYN_RECV.
> 
> For instance, a REDIRECT on SYN_RECV shall be ignored, as we do
> not hold a dst per SYN_RECV pseudo request.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=111751
> Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
> Reported-by: Petr Novopashenniy <pety@rusnet.ru>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
