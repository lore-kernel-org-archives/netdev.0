From: Ben Greear <greearb@candelatech.com>
Subject: Re: How to grab a block of binary data w/out using ioctls?
Date: Wed, 25 Oct 2006 09:30:02 -0700
Message-ID: <453F910A.3040801@candelatech.com>
References: <453D61E8.8020400@candelatech.com> <20061023215448.f4f6c95a.randy.dunlap@oracle.com> <20061024050014.GC12506@havoc.gtf.org> <453ECB2C.3070202@candelatech.com> <20061025024718.GB23769@havoc.gtf.org> <20061024213549.92cbbeb0.randy.dunlap@oracle.com> <20061025044621.GA32486@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:16274 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1423163AbWJYQdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 12:33:49 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20061025044621.GA32486@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> On Tue, Oct 24, 2006 at 09:35:49PM -0700, Randy Dunlap wrote:
>   
>>> Please grep for sysfs_create_bin_file, you will find plenty of examples.
>>>       
>> Hm, I thought that sysfs binary files were supposed to be
>> for "transparent" blobs of data, not for structured data.
>> E.g., a "firmware" blob would be OK.
>>     
>
> Depends.  Normally ASCII is greatly preferred, but passing in/out big
> data structures can be a huge pain, thunking to/from ASCII.
>   
This is my scenario exactly.  It is also much easier to make sure the 
data is
coherent if I can grab it all at once.

In my case, I'm wanting to add this to the pktgen module, for reporting 
stats.  But,
it seems sysfs is designed mostly for drivers with some sort of 'object' 
behind it.

Would I need to create some faked out dummy object in order to use sysfs 
with
pktgen?

I also notice there is already a /sys/modules/pktgen node in sysfs..is 
there any easy way to
stick my binary file interface in that directory?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


