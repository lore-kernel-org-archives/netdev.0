From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: AR-M0898A and tg3 driver Kernel Corruption/Panic
Date: Tue, 01 Feb 2011 10:30:17 -0500
Message-ID: <4D482709.7020701@earthlink.net>
References: <4D472C6A.9050605@iplink.net> <20110131220425.GA3540@mcarlson.broadcom.com>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Sullivan <scott@iplink.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:48079 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751185Ab1BAPaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 10:30:20 -0500
In-Reply-To: <20110131220425.GA3540@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2011 05:04 PM, Matt Carlson wrote:
> On Mon, Jan 31, 2011 at 01:40:58PM -0800, Scott Sullivan wrote:
>    
>> Stephen Clark,
>>
>> I've been fighting with Installing CentOS 5.5 on the Acrosser AR-M0898B. After finally Narrowing down the issue to the tg3 driver I stumbled upon your thread with Matt Carlson (CC'd).
>>
>> First up, what is the canonical location to follow the thread from? (It's mirrored to all ends of the Internet making it hard to find the most update copy of it.)
>>
>> As for my experiences with the device:
>> Getting the appliance to run right for me required the kernel arguments:
>> "apci=off nolapic"
>>
>> CentOS installs with tg3 Version 3.106
>> - w/o args system outright reboot when trying to start networking
>> - w/ args system would try to get DHCP and corrupt the kernel resulting in "cannot execute binary file" errors
>>
>> After installing tg3 Version 3.110g from src rpm:
>> - w/ args, gives a proper kernel panic and dump when trying to get a DHCP address.
>>
>> An old vague email from Acrosser suggest something stopped working between Fedora 8 and Fedora 10. I've yet to dig deeper into that lead.
>>
>> I have 2 of these devices on my desk. Please let me know if there is any information or tests I can preform to assist in resolving this bug.
>>      
> Thanks Scott.  Both you and Stephen seem to be running newer kernels and
> running into problems.  It doesn't look like the hardware is all that
> new though.  To see if there is a lower bound, have you tried running
> older distros to see if any one of them clears up the problem?
>
> Another approach is to do a kernel git bisection.  Is anyone comfortable
> with that?
>
>    
Hi Matt & Scott,

Actually I started out with the current kernel from Centos 5.5 and
tried later kernels to see if the problem was fixed, which it wasn't.

I haven't gotten around to testing a boot with the nomsi option yet.

Also I couldn't get freebsd 6.3 to run either.

Regards,
Steve

