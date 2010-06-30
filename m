From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: nat bypass
Date: Wed, 30 Jun 2010 08:05:45 -0400
Message-ID: <4C2B3319.5040306@earthlink.net>
References: <AANLkTil_H1QeaCHQYhMjVRFiLwtqF9yLAJZ9BWecOIDW@mail.gmail.com>	<20100630023718.GU2138@verge.net.au> <AANLkTilxqHHiDfzQbewBe8cnTtvdB9CCTPn9EVCcAf5Q@mail.gmail.com>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
	Netfilter mailing list <netfilter@vger.kernel.org>,
	netdev@vger.kernel.org
To: ratheesh k <ratheesh.ksz@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <AANLkTilxqHHiDfzQbewBe8cnTtvdB9CCTPn9EVCcAf5Q@mail.gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/30/2010 05:24 AM, ratheesh k wrote:
>> Let me try and understand this.
>>
>> R is routing between 192.168.1.0/24 and 10.232.18.0/24.
>> As A is on the 192.168.1.0/24 side of R.
>> But to give A an 10.232.18.0/24 address (dynamically)?
>>
>> Why?
>>
>
> For some clients , R should act as a mere bridge , Not a router .
>
>
> On Wed, Jun 30, 2010 at 8:07 AM, Simon Horman<horms@verge.net.au>  wrote:
>> On Mon, Jun 28, 2010 at 03:43:46PM +0530, ratheesh k wrote:
>>> Hi,
>>>
>>>    A ------->  R ------->S
>>>
>>> I have a linux machine A is connected to Linux machine R . Machine R
>>> is having two network interfaces and acting as a router .
>>> It has a dhcp server running  . It will assign ip in 192.168.1.0/24
>>> subnet to all machine connected on lan side ( A is connected also in
>>> lan side ) . Wan side of R is connected to HTTP server S . There is
>>> also a DHCP server running on S to assign ip in 10.232.18.0/24 subnet
>>> .  Is there any way , in which NAT should be bypassed to get ip from
>>> DHCP server running  on S . My question is : How can A will get  an ip
>>> from 10.232.18.0/24 pool ip .?
>>> ebtables is an option ? How can we make it ?
>>> Is there any other optimal way ?
>>
>> Let me try and understand this.
>>
>> R is routing between 192.168.1.0/24 and 10.232.18.0/24.
>> As A is on the 192.168.1.0/24 side of R.
>> But to give A an 10.232.18.0/24 address (dynamically)?
>>
>> Why?
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
Will dhcprelay work for you?

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)


