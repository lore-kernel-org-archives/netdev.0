From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net: Add etun driver
Date: Fri, 06 Apr 2007 20:31:51 -0700
Message-ID: <461710A7.4040108@candelatech.com>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>	<4616B9A5.7090800@candelatech.com> <m1y7l53pl8.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:53985 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbXDGDdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2007 23:33:07 -0400
In-Reply-To: <m1y7l53pl8.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Ben Greear <greearb@candelatech.com> writes:
>
>   
>> Is there any way to tell for certain if an interface is a etun or not?  Maybe
>> a file could be found (or not) in sysfs somewhere?
>>     
>
> Link for any decent network driver ethtool -i <interface>
>   
I guess that will do, but then if you ever change the strings, any 
user-space that is
depending on this will break or have to be modified with additional 
cruft.  It seems
cleaner to me to have an ioctl or a specific place in /proc or some 
other virtual
fs, but I can deal with it either way...

>> Also, how do you find the peer device from user-space?  This would be very
>> useful
>> for anyone trying to manage these devices with a user-space program.
>>     
>
> Currently "ethtool -S <interface>"
> And read the partner_ifindex.
>   
Ok, that will work.  Again, my personal preference is for a single 
specific ioctl or proc'ish file
to read the specific value instead of having to parse strings, but this 
will do.

> Further whoever generates the pair specifies the initial set of names.
>   
Yeah, but you can't depend on knowing that in an interesting environment.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


