From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Fixed checkpatch warnings and errors
Date: Tue, 08 May 2012 13:01:39 -0400 (EDT)
Message-ID: <20120508.130139.515602646900287732.davem@davemloft.net>
References: <1336474704-9366-1-git-send-email-cristian.chilipirea@gmail.com>
	<4FA9382A.9090709@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cristian.chilipirea@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	daniel.baluta@gmail.com
To: greearb@candelatech.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FA9382A.9090709@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 08 May 2012 08:13:46 -0700

> On 05/08/2012 03:58 AM, Cristian Chilipirea wrote:
>> Fixed warnings and errors in af_inet.c.
> 
>>   #ifdef CONFIG_COMPAT
>> -static int inet_compat_ioctl(struct socket *sock, unsigned int cmd,
>> -unsigned long arg)
>> +static int inet_compat_ioctl(struct socket *sock, unsigned int cmd,
>> +		unsigned long arg)
>>   {
> 
> That is so much worse than what was there before.
> 
> Lets stop useless checkpatch crap on existing code
> unless it's really ugly.

Agreed, this patch is terrible.
