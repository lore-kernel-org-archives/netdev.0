From: Ben Greear <greearb@candelatech.com>
Subject: Re: Strange igb bug, out-of-tree driver seems to work fine.
Date: Thu, 21 Apr 2011 20:43:33 -0700
Message-ID: <4DB0F965.4080605@candelatech.com>
References: <4DB0A3FF.8080203@candelatech.com> <EDC0E76513226749BFBC9C3FB031318F01382E2CEF@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50014 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753998Ab1DVDnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 23:43:35 -0400
In-Reply-To: <EDC0E76513226749BFBC9C3FB031318F01382E2CEF@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/21/2011 05:16 PM, Wyborny, Carolyn wrote:
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of Ben Greear
>> Sent: Thursday, April 21, 2011 2:39 PM
>> To: netdev
>> Subject: Strange igb bug, out-of-tree driver seems to work fine.
>>
>> We have a 4-port NIC using the igb driver in a couple of systems,
>> and saw some strange issues (mostly rx CRC errors).  We tried 2.6.34,
>> 2.6.36, and 2.6.38 based kernels and all showed issues.  The NICs
>> are from two different vendors, though both use the igb driver.
>>
>> We then tried 2.6.36.3 with the out-of-tree igb-2.4.13.tar.gz
>> driver.  And everything seems to run clean.
>>
>> My kernels are somewhat hacked and tainted, and this testing
>> is using my tainting module, but since changing only the driver
>> seems to fix things, it's _probably_ not my fault this time!
>>
>> I am running a small hack to make igb work better with VLANs
>> in my 2.6.36 and .38 kernel, though not in the .34.  Here is the .36
>> diff:

>
> Hello,
>
> There have been recent patches for igb that I submitted that might contain the fix you found in the out-of-tree driver, although I'm not sure which one would affect rx CRC errors.  Were there other symptoms?  Any messages in the log?  I'll look through the patches and see if there is anything obvious and get you some commit numbers to try.

There was nothing else that I noticed.  If your patches are in 2.6.39-rc4+, I can try
them there perhaps?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
