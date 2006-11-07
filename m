From: John Heffner <jheffner@psc.edu>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Tue, 07 Nov 2006 17:29:02 -0500
Message-ID: <455108AE.80704@psc.edu>
References: <1162924354.10806.172.camel@localhost.localdomain>	<20061107.124557.21592397.davem@davemloft.net>	<4550FFA9.8040503@psc.edu> <20061107.142200.115911407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tim.c.chen@linux.intel.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:48636 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S1752538AbWKGWaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 17:30:55 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061107.142200.115911407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: John Heffner <jheffner@psc.edu>
> Date: Tue, 07 Nov 2006 16:50:33 -0500
> 
>> The only stack I know of that does this currently is linux, and in doing 
>> so does not conform to the spec. ;)  Sending to a BSD receiver will 
>> result in the same behavior, so the "right place" to fix this is on the 
>> sending side.  (I know the issue of packet vs. byte counting has come up 
>> many times over the last 10 years or so, and many arguments have been 
>> made on either side... I don't mean this to be flame bait but it's clear 
>> what will happen in this scenario.)
> 
> John, you cannot change the N-million existing Linux systems
> out there doing congestion control via byte counting.  You
> cannot do this no matter how much you wish it so :-)

That would make our lives easier, wouldn't it? ;)  Clearly there are 
some combinations of TCP stacks out there that won't interoperate well 
under certain workloads.  Making new versions of the stack work well is 
the best we can hope for...

Fixing the sending side does not mean we have to back out the 
work-around on the receiving side.

   -John
