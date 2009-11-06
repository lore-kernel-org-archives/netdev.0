From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 02/02: xt_connlimit: fix regression caused by zero
 family value
Date: Fri, 06 Nov 2009 00:44:18 -0800 (PST)
Message-ID: <20091106.004418.54906158.davem@davemloft.net>
References: <4AF31818.3030103@trash.net>
	<alpine.LSU.2.00.0911051943130.25147@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0911051943130.25147@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>
Date: Thu, 5 Nov 2009 19:45:25 +0100 (CET)

> On Thursday 2009-11-05 19:23, Patrick McHardy wrote:
>>
>>    netfilter: xt_connlimit: fix regression caused by zero family value
>>    
>>    Commit v2.6.28-rc1~7172~1092~2 was slightly incomplete; not all
>>    instances of par->match->family were changed to par->family.
>>    
>>    Netfilter bugzilla #610.
> 
> Hold it.
> git would never output ~7172~1092~2 because ~8266 would be much simpler.
> 
> I originally wrote "Commit v2.6.28-rc1~717^2~109^2~2", but one of your 
> programs seems to eat commit messages or more.

Guys, please sort this out so I can add this fix to net-2.6

Thanks.
