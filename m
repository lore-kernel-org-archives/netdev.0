From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: Wed, 12 Jan 2005 15:43:52 -0800
Message-ID: <41E5B638.8070007@candelatech.com>
References: <20050112222437.GC14280@xi.wantstofly.org> <41E5A7E9.4030101@candelatech.com> <20050112224810.GE14280@xi.wantstofly.org> <41E5AEAC.8060706@candelatech.com> <20050112231615.GF14280@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050112231615.GF14280@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Wed, Jan 12, 2005 at 03:11:40PM -0800, Ben Greear wrote:
> 
> 
>>>>Also, could you add an ioctl that allowed one to query whether or not
>>>>a particular device is an etherip device?  I had always wished I had added
>>>>this earlier to the VLAN code :)
>>>
>>>Hmmm.  Bridge devices don't have this either, do they?  Can you name
>>>an advantage of having this?
>>
>>I got the request several times with regard to VLANs.  Lots of people
>>(and applications) will want to know the interface type for various
>>reasons.  If you don't give them a nice programatic thing like an
>>IOCTL to call, they will undoubtedly start making assumptions based
>>off of the device name...
> 
> 
> Makes sense..
> 
> Unfortunately SIOCGETTUNNEL is (SIOCDEVPRIVATE + 3), otherwise we could
> just say something like "If an ARPHRD_ETHER device supports SIOCGETTUNNEL,
> it's an ether/ip tunnel."
> 
> Any better ideas?  I hate adding more ioctls.

How about add one IOCTL that takes a small (naturally packed/aligned, fixed-size!)
struct that has within it an enumeration of specific commands and whatever fields
are needed for arguments.  Then you only need to add a single IOCTL to the system,
and you can add more commands at will.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
