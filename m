From: Patrick McHardy <kaber@trash.net>
Subject: Re: error while building the kernel Mainline
Date: Thu, 18 Nov 2010 22:48:47 +0100
Message-ID: <4CE59F3F.3080407@trash.net>
References: <20101118.125451.98885354.davem@davemloft.net>	<20101118130318.073f6beb.randy.dunlap@oracle.com>	<20101118.131004.58430322.davem@davemloft.net> <20101118.131527.45904827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, justinmattock@gmail.com,
	eric.dumazet@gmail.com, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	horms@verge.net.au, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101118.131527.45904827.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 18.11.2010 22:15, schrieb David Miller:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 18 Nov 2010 13:10:04 -0800 (PST)
> 
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>> Date: Thu, 18 Nov 2010 13:03:18 -0800
>>
>>> On Thu, 18 Nov 2010 12:54:51 -0800 (PST) David Miller wrote:
>>>
>>>> From: Patrick McHardy <kaber@trash.net>
>>>> Date: Thu, 18 Nov 2010 21:32:11 +0100
>>>>
>>>>> Thanks for testing. Dave, please apply directly, thanks!
>>>
>>> Dave,
>>>
>>> This patch does not fix the config/build error that I posted for linux-next.
>>
>> And it has bugs, now when NF_CONNTRACT is set to "m" IPVS isn't offered
>> at all.
>>
>> So I'm reverting.
> 
> Ignore this, I was looking for "*_IPVS" in the config instead of
> "*_IP_VS" for some stupid reason.

I always make the same mistake :)

> Patch is sane and I'll look into Randy's problem when I get a chance.
> :-)

I've already asked the tproxy guys to look into this, it's a
different problem that requires more tproxy knowledge than
have.
