From: David Miller <davem@davemloft.net>
Subject: Re: skbuff truesize incorrect.
Date: Fri, 23 May 2014 12:46:04 -0400 (EDT)
Message-ID: <20140523.124604.1978823006121667147.davem@davemloft.net>
References: <537E5C63.7080607@mentor.com>
	<20140522.165833.414855217799383878.davem@davemloft.net>
	<537F130F.6080901@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kamal@canonical.com,
	bhutchings@solarflare.com, edumazet@google.com, mszeredi@suse.cz,
	fw@strlen.de
To: jim_baxter@mentor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537F130F.6080901@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jim Baxter <jim_baxter@mentor.com>
Date: Fri, 23 May 2014 10:21:19 +0100

> On 22/05/14 21:58, David Miller wrote:
>> From: Jim Baxter <jim_baxter@mentor.com>
>> Date: Thu, 22 May 2014 21:21:55 +0100
>> 
>>> If there are multiple clones for an skb all pointing at the same data,
>>> will that distort the memory used when they all have the same truesize?
>> 
>> What is distorted about it?
>> 
>> Each clone references exactly that much backing memory.
>>
> 
> Thank you for you help, I think distorted was the wrong word.
> 
> 
> I think I am confused what truesize is used for it looks like it is used
> to deallocate memory, is this correct?

It's used to determine how much to charge sockets against their read
and write memory limits.
