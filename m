From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH][RFC] etherip: Ethernet-in-IPv4 tunneling
Date: Wed, 12 Jan 2005 15:11:40 -0800
Message-ID: <41E5AEAC.8060706@candelatech.com>
References: <20050112222437.GC14280@xi.wantstofly.org> <41E5A7E9.4030101@candelatech.com> <20050112224810.GE14280@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org, rhousley@rsasecurity.com,
        shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050112224810.GE14280@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Wed, Jan 12, 2005 at 02:42:49PM -0800, Ben Greear wrote:
> 
> 
>>Why do you add a single device when loading the module?  Is this just
>>so you have something to hook the ioctl to?
>>
>>My personal preference would be something where you do not automatically
>>create an etherip0, but would have an etherip-config tool or similar to
>>create/destroy interfaces.
> 
> 
> I modelled this after the way ipip/gre/sit do things -- they create
> tunl0/gre0/sit0, and have 'ip tunnel' send its ioctls to those devices.
> 
> I wouldn't mind changing this to another mechanism, but 1) we'd have to
> agree on a mechanism, and 2) we'd have to change the other tunnel types
> over to this mechanism as well.

Ok, it's not a big deal to me.

>>Also, could you add an ioctl that allowed one to query whether or not
>>a particular device is an etherip device?  I had always wished I had added
>>this earlier to the VLAN code :)
> 
> 
> Hmmm.  Bridge devices don't have this either, do they?  Can you name
> an advantage of having this?

I got the request several times with regard to VLANs.  Lots of people
(and applications) will want to know the interface type for various
reasons.  If you don't give them a nice programatic thing like an
IOCTL to call, they will undoubtedly start making assumptions based
off of the device name...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
