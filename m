From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net_sched: make traffic control network namespace aware
Date: Mon, 22 Mar 2010 19:04:44 +0100
Message-ID: <4BA7B13C.7020304@trash.net>
References: <20100320014013.GC13239@boeing.com> <4BA7AF32.8020001@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Goff <thomas.goff@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40327 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209Ab0CVSEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 14:04:44 -0400
In-Reply-To: <4BA7AF32.8020001@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Tom Goff wrote:
>> Mostly minor changes to add a net argument to various functions and
>> remove initial network namespace checks.
>>
>> Make /proc/net/psched per network namespace.
> 
> Looks fine from a qdisc POV. One thing that appears to be missing
> though is teql master netdev registration in other than the initial
> namespace.

Actually we could take this opportunity and add rtnl_link support
for teql device registration. I can look into this in a couple of
days.
