From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection stops after high load.
Date: Wed, 11 Apr 2007 14:31:00 -0700
Message-ID: <461D5394.9040409@candelatech.com>
References: <461D447C.4070408@candelatech.com>	<20070411.134804.50594117.davem@davemloft.net>	<461D4DD7.7020207@candelatech.com> <20070411.141143.82097512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:42431 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932184AbXDKVbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 17:31:03 -0400
In-Reply-To: <20070411.141143.82097512.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Wed, 11 Apr 2007 14:06:31 -0700
> 
>> Does the CWND == 1 count as solid?  Any idea how/why this would go
>> to 1 in conjunction with the dup acks?
>>
>> For the dup acks, I see nothing *but* dup acks on the wire...going in
>> both directions interestingly, at greater than 100,000 packets per second.
>>
>> I don't mind adding printks...and I've started reading through the code,
>> but there is a lot of it, and indiscriminate printks will likely just
>> hide the problem because it will slow down performance so much.
> 
> If you know that it doesn't take Einstein to figure out that maybe you
> should add logging when CWND is one and we're sending out an ACK?
 >
> This is why I think you're very lazy Ben and I get very agitated with
> all of your reports, you put zero effort into thinking about how to
> debug the problem even though you know full well how to do it.

I've spent solid weeks tracking down obscure races.  I'm hoping that
someone who knows the tcp stack will have some idea of places to look
based on the reported symptoms so that I don't have to spend another
solid week chasing this one.  If not, so be it..I'm still working on
this between sending emails.  For what it's worth, the problem (or something similar)
is reproducible on a stock FC5 .18-ish kernel as well, running between
two machines, 2 ports each.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

