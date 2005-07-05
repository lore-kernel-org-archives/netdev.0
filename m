From: Patrick Jenkins <patjenk@wam.umd.edu>
Subject: Re: [PATCH] multipath routing algorithm, better patch
Date: Tue, 5 Jul 2005 11:17:35 -0400 (EDT)
Message-ID: <Pine.GSO.4.61.0507051114310.15834@rac3.wam.umd.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>Thomas Graf wrote:
>> * Patrick McHardy <42C4919A.5000009@trash.net> 2005-07-01 02:43
>>
>>>If it isn't set correctly its an iproute problem. Did you actually
>>>experience any problems?
>>
>> Well, my patch for iproute2 to enable multipath algorithm selection
>> is currently being merged to Stephen together with the ematch bits.
>> We had to work out a dependency on GNU flex first (the berkley
>> version uses the same executable names) so the inclusion was
>> delayed a bit.
>
>So its no problem but simply missing support. BTW, do you know if
>Stephen's new CVS repository is exported somewhere?

Yes, we did experience a problem. The routing doesnt work as advertised 
(i.e. it wont utilize the multiple routes). Patrick is correct in saying 
its missing support.

>From what you are saying it seems the problem will be corrected by a new 
feature in iproute2 that allows the user to select this ability. Is this 
correct? Also, does this mean my patch is not needed? It seems to me that 
it should be supported somehow in the kernel seeing as how everyone might 
not utilize iproute2.

Once again, please cc me in the reply because I am not a member of the 
list.

Thanks,
Patrick Jenkins
