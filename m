From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1] tproxy: do not assign timewait sockets to skb->sk
Date: Thu, 17 Feb 2011 11:40:13 +0100
Message-ID: <4D5CFB0D.9050704@trash.net>
References: <1297683874-10188-1-git-send-email-fw@strlen.de> <4D594F9E.2090100@trash.net> <4D5B90C7.5040603@balabit.hu> <20110216113040.GE8821@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: KOVACS Krisztian <hidden@balabit.hu>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53086 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337Ab1BQKkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 05:40:16 -0500
In-Reply-To: <20110216113040.GE8821@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 16.02.2011 12:30, schrieb Florian Westphal:
> KOVACS Krisztian <hidden@balabit.hu> wrote:
>> On 02/14/2011 04:51 PM, Patrick McHardy wrote:
>>> Looks fine to me. Balazs. Krisztian, any objections?
>>
>> Seems to be OK, as far as I can see.
>>
>> Florian, did you make sure the tests still run after applying this patch?
>>
>> http://git.balabit.hu/?p=bazsi/tproxy-test.git;a=summary
> 
> Thanks for the hint, I cloned this and ran it on my test setup:
> ./tproxy-test.py
> [..]
> PASS: ('192.168.10.8', 50080), we got a connection as we deserved
> PASS: everything is fine

Applied, thanks everyone.

