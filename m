From: Andy Furniss <andy.furniss@dsl.pipex.com>
Subject: Re: IMQ / new Dummy device post.
Date: Sun, 18 Apr 2004 21:34:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4082E66D.2020707@dsl.pipex.com>
References: <407E5905.9070108@dsl.pipex.com>	 <1082031313.1039.13.camel@jzny.localdomain>	 <407EE3E5.8060200@dsl.pipex.com>	 <1082087553.1035.287.camel@jzny.localdomain>	 <4080356F.4020609@dsl.pipex.com>	 <1082145341.1026.125.camel@jzny.localdomain>	 <40810957.6030209@dsl.pipex.com>	 <1082203795.1043.18.camel@jzny.localdomain>	 <4081A824.5020107@dsl.pipex.com> <1082298480.1041.94.camel@jzny.localdomain> <4082AE45.7030101@dsl.pipex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Furniss <andy.furniss@dsl.pipex.com>
In-Reply-To: <4082AE45.7030101@dsl.pipex.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andy Furniss wrote:
<snip>

>> To accomodate your need for b), the idea would be as follows:
>> packet gets demasquared, mark it with a fwmark
> 
> 
> I guess you really mean mark then demasquerade.
> 
>> based on some recognition
>> you have for bittorent or squid and lastly policy route it to the dummy
>> device based on fwmark (since routing happens last).
>> I will need to modify the dummy to not drop such packets which are
>> fwmarked. 
> 
> 
> OK I can see this as a possibility - assuming I can mark. Maybe conmark 
> will be OK with connbytes sometime. I don't really know how to use it, 
> but if it is possible to mark egress connections in output and have 
> connmark match their incoming packets that would be a solution. I 
> haven't got a clue if connmark can do this, though, just speculating.

Hmm second thoughts - if I can route packets to dummy after demasquerade 
then I don't need to mark - I can use u32 as I do now to seperate per 
IP. Am I missing something here?

> 
> Does anyone else know, and why it's not compatable with connbytes?
> 
> Andy.
> 
>> cheers,
>> jamal
>>
>>
>>
> 
> 
> 
> 
