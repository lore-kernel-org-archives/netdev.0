From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Thu, 11 Jul 2002 15:34:54 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D2DDDDE.2040008@mandrakesoft.com>
References: <Pine.LNX.4.44.0207111238570.2498-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
List-Id: netdev.vger.kernel.org

Donald Becker wrote:
> On Thu, 11 Jul 2002, Jeff Garzik wrote:
> 
>>Donald Becker wrote:
>>
>>>The mdelay(300) is completely bogus.
>>
> ...
> 
>>Ouch.  You are absolutely right, and I take the blame for not reviewing 
>>more closely.  That's what I get for trusting vendors too much ;-)
>>[D-Link has been the one patching sundance and dl2k for a while now]
> 
> 
> Very, very few vendor patchs are worth applying.  They sometimes know of
> otherwise undocumented chip bugs, but a lot of the actual code is bad.
> 
> It's not "maintaining" a driver when you just take a vendor modification
> of a driver and assume it's OK.  You have to understand the changes and
> evaluate if they make sense.

I never claimed to maintain sundance ;-)  Not having docs and test 
hardware tends to narrow the field a bit.


>>I've been meaning to go through several drivers and fix up the stupid 
>>assumptions they make about autonegotiation completion time.
> 
> 
> Putting broken changes into the kernel with a plan to go back later and
> clean them is a bad development methodology.

That depends on the change.  mdelay(300) is a case of "stupid but 
usually works" not completely broken.  As long as it's forward progress 
that gets something working, I would rather apply now and fix up later. 
  That reduces the overall brokenness time a user must deal with.

I'm accepting patches to clean up sundance, if someone with test 
hardware is willing to compare your driver and the kernel's.

	Jeff
