From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Fri, 03 Jan 2003 20:52:13 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E163E4D.5090007@pobox.com>
References: <Pine.LNX.4.44.0301032029540.29812-100000@beohost.scyld.com> <3E163CBB.30206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Donald Becker <becker@scyld.com>, jamal <hadi@cyberus.ca>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3E163CBB.30206@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Donald Becker wrote:
> 
>> It was
>>   "If you need this capability for a RESEARCH PROJECT, you can buy this
>>   specific board and thus not need to modify the kernel or device
>>   driver. "
>>
>> You can also find a few people that want to receive specific corrupted
>> packets, change the meaning of LEDs on a NIC, and do many other strange
>> things.  But we don't need a defined kernel interface for each one.
> 
> 
> Just out of curiosity, what is the suggested manner for adding such
> back-door hacks as this?

SIOCDEVPRIVATE is staying around


 > Maybe in a proc file system that the driver
> implements?

No!  procfs additions are discouraged.  sysfs in 2.5.x if you _must_ do 
this, but SIOCDEVPRIVATE or just flat out maintaining a kernel patch 
against a stable kernel tree would be much preferred, I think.


 > It would be neat to see various driver-specific features
> like this be implemented, and it would be even nicer if they followed
> at least some general guideline for how to interface with the rest of
> the world...


Driver-specific features are by definition just that :)  If you want a 
general guideline, you'll also want a header or helper lib quite often 
to eliminate duplication of code and standardize the interface.

	Jeff
