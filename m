From: Ben Greear <greearb@candelatech.com>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 10:18:56 -0700
Message-ID: <47027D80.4070506@candelatech.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <20071002154137.GD17418@bitmover.com> <4702766E.80202@candelatech.com> <20071002171154.GM17418@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: lm@bitmover.com, Ben Greear <greearb@candelatech.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:56929 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754940AbXJBRTO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 13:19:14 -0400
In-Reply-To: <20071002171154.GM17418@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry McVoy wrote:
>> I have a more complex configuration & application, but I don't see this 
>> problem in my testing.  Using e1000 nics and modern hardware 
>>     
>
> I'm using a similar setup, what kernel are you using?
>   
I'm currently on 2.6.20, and have also tried 10gbe nics on 2.6.23 with
good results.  At least for my app, performance has been pretty steady
at least as far back as the .18 kernels, and probably before....

I do 64k or smaller writes & reads, and non-blocking IO (not sure if that
would matter..but I do :)

Have you tried something like ttcp, iperf, or even regular ftp?

Checked your nics to make sure they have no errors and are negotiated
to full duplex?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


