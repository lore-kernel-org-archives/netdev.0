From: Ben Greear <greearb@candelatech.com>
Subject: Re: 8169 driver with NetGear GA511 card.
Date: Thu, 28 Oct 2004 15:49:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41817789.4000703@candelatech.com>
References: <41802CA8.8070900@candelatech.com> <20041028074827.GA3572@electric-eye.fr.zoreil.com> <418130C4.3010207@candelatech.com> <20041028223754.GA20521@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041028223754.GA20521@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Ben Greear <greearb@candelatech.com> :
> [...]
> 
>>I'm running tests at the ethernet frame (skb) level, so I would not
>>expect the IP offload to help much.
>>
>>Do you have any performance numbers for your 8169 cards for me to
>>compare against?
> 
> 
> Gross numbers:
> - with a receiving amd64, nttcp should saturate the GigaE link;
> - halved bandwidth for Tx on the same setup. Untested since changes in -mm;
> - 10% cpu on a 100bt link;
> - TSO saves 5~7% of the cpu when it can be used.

Cool, I am glad to know the chipset can handle it at least...

>>I'll get this in a bit, as I have locked up the keyboard again.  This time,
>>I was still using the non-NAPI code which had run over-night at around 
>>5Mbps...
>>
>>I tried a different network setup, and noticed that the 8169 was only
>>negotiating 10bt/HD.  That would explain the poor performance numbers.
> 
> Call me dense but... Are the 5Mbps below in the same unit as the 30Mbps
> in your previous message (are they bytes or bits) ? If yes something is
> badly broken.

Yes, but I think now the problem is that it was stuck at 10bt/HD for whatever
reason.  There seems to be a way to lock the keyboard by trying to make the
NIC change it's negotiate settings.  I am going to try to track down exactly
how this can be reproduced with minimum number of steps...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
