From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection stops after high load.
Date: Fri, 13 Apr 2007 09:42:33 -0700
Message-ID: <461FB2F9.4010600@candelatech.com>
References: <461D2DEA.4010806@candelatech.com> <461D447C.4070408@candelatech.com> <20070411.134804.50594117.davem@davemloft.net> <461D4DD7.7020207@candelatech.com> <p73y7kx7iol.fsf@bingen.suse.de> <461E7377.3020708@candelatech.com> <20070412201940.7f570b6d.dada1@cosmosbay.com> <461E8496.2050003@candelatech.com> <461E998A.8080409@cosmosbay.com> <461EA662.5090801@candelatech.com> <20070413070951.GB2138@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	bcrl@kvack.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:57085 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754095AbXDMQnf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2007 12:43:35 -0400
In-Reply-To: <20070413070951.GB2138@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Thu, Apr 12, 2007 at 02:36:34PM -0700, Ben Greear (greearb@candelatech.com) wrote:
>   
>> I am not sure if the problem is fixed or just harder to hit,
>> but for now it looks good.
>>     
>
> Wasn't default congestion control algo changed between that kernel
> releases?
> With such small rtt like in your setup there could be some obscure bug,
> try to set different one and check if it still works good/bad.
>   
I had earlier tried changing between bic and reno (the only two I had 
compiled in
that kernel), and it did not affect anything.  I also realized that I 
had been reproducing
the bug (and the traces I sent to this list earlier) on a 2.6.17.4 
kernel..not 2.6.18 as
I had supposed.  So, it's possible that the problem was fixed between 
2.6.17.4 and
2.6.18.2 as well.

I also figured out yesterday that rebooting to go to a new kernel makes 
it slower
to reproduce, even on kernels known to have the problem.  This is 
probably because
lots of memory is available after a reboot.  I am going to set up
some long term tests on 2.6.18, 2.6.19 and 2.6.20 and let them cook for 
several
days to make sure the problem is truly fixed in the later kernels.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


