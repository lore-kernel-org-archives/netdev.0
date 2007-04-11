From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection stops after high load.
Date: Wed, 11 Apr 2007 14:06:31 -0700
Message-ID: <461D4DD7.7020207@candelatech.com>
References: <461D2DEA.4010806@candelatech.com>	<461D447C.4070408@candelatech.com> <20070411.134804.50594117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:45405 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbXDKVGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 17:06:34 -0400
In-Reply-To: <20070411.134804.50594117.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Wed, 11 Apr 2007 13:26:36 -0700
> 
>> Interestingly, I found this page mentioning a SACK problem in Linux:
>> http://www-didc.lbl.gov/TCP-tuning/linux.html
> 
> Don't read that page, it is the last place in the world your should
> take hints and advice from, most of the problems they speak of there
> have been fixed years ago.

Much of their memory and buffer settings are similar to what I've
seen elsewhere..and what I use, but it could be we're all getting
the same info from the same faulty source.  Suggestions of a proper
site for tuning TCP for high speed/high latency links are welcome.

> Please start instrumenting the TCP code instead of "poking around"
> hoping you'll hit the grand jackpot by manipulating some sysctl
> setting.
> 
> It doesn't help us and it won't help you, start reading and
> understanding the TCP code, add debugging printk's, anything to get
> more information about this.
> 
> And please don't report anything here until you have some solid piece
> of debugging information, else I'll just sit here replying and
> prodding you along ever so slowly. :(

Does the CWND == 1 count as solid?  Any idea how/why this would go
to 1 in conjunction with the dup acks?

For the dup acks, I see nothing *but* dup acks on the wire...going in
both directions interestingly, at greater than 100,000 packets per second.

I don't mind adding printks...and I've started reading through the code,
but there is a lot of it, and indiscriminate printks will likely just
hide the problem because it will slow down performance so much.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

