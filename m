From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC NET 00/04]: Increase number of possible routing tables
Date: Fri, 07 Jul 2006 22:06:29 -0700
Message-ID: <44AF3D55.8040004@candelatech.com>
References: <20060703075259.6286.67397.sendpatchset@localhost.localdomain> <44AE15C3.8050900@trash.net> <44AEA462.1080505@candelatech.com> <44AEBCE7.2030203@trash.net> <44AF053F.70605@candelatech.com> <44AF1CFD.102@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>, Robert.Olsson@data.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:20956 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1750773AbWGHFGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jul 2006 01:06:49 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44AF1CFD.102@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Ben Greear wrote:
> 
>>With this patch applied everything is looking much better.  I currently
>>have 400+ interfaces and one routing table per interface, and traffic
>>is passing as expected.
>>
>>This is probably due to my own application polling interfaces for
>>stat updates...but I am seeing over 50% usage (with more system than
>>user-space)
>>in this setup on an otherwise lightly loaded system.  top shows no
>>process averaging
>>more than about 2% CPU (and only 2-3 are above 0.0 typically), which I find
>>a little strange.  load is around 3.0.
> 
> 
> I can't imagine this beeing related to the increased number of
> routing tables, with a number of entries slightly (not even two
> times) over the hash size it shouldn't make that much of a
> difference. It may of course be a bug, but I don't see it.

I think it was my polling logic that was the problem.  I fixed it up to
be more clever and the load went away.

Ben

> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

