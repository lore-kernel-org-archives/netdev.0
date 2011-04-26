From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: Strange igb bug, out-of-tree driver seems to work fine.
Date: Tue, 26 Apr 2011 16:23:02 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F016B41256F@orsmsx508.amr.corp.intel.com>
References: <4DB0A3FF.8080203@candelatech.com>
 <EDC0E76513226749BFBC9C3FB031318F01382E2CEF@orsmsx508.amr.corp.intel.com>
 <4DB0F965.4080605@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34344 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753958Ab1DZXXI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 19:23:08 -0400
In-Reply-To: <4DB0F965.4080605@candelatech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Ben Greear [mailto:greearb@candelatech.com]
>Sent: Thursday, April 21, 2011 8:44 PM
>To: Wyborny, Carolyn
>Cc: netdev
>Subject: Re: Strange igb bug, out-of-tree driver seems to work fine.
>
>On 04/21/2011 05:16 PM, Wyborny, Carolyn wrote:
>>
>>
>>> -----Original Message-----
>>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>owner@vger.kernel.org]
>>> On Behalf Of Ben Greear
>>> Sent: Thursday, April 21, 2011 2:39 PM
>>> To: netdev
>>> Subject: Strange igb bug, out-of-tree driver seems to work fine.
>>>
>>> We have a 4-port NIC using the igb driver in a couple of systems,
>>> and saw some strange issues (mostly rx CRC errors).  We tried 2.6.34,
>>> 2.6.36, and 2.6.38 based kernels and all showed issues.  The NICs
>>> are from two different vendors, though both use the igb driver.
>>>
>>> We then tried 2.6.36.3 with the out-of-tree igb-2.4.13.tar.gz
>>> driver.  And everything seems to run clean.
>>>
>>> My kernels are somewhat hacked and tainted, and this testing
>>> is using my tainting module, but since changing only the driver
>>> seems to fix things, it's _probably_ not my fault this time!
>>>
>>> I am running a small hack to make igb work better with VLANs
>>> in my 2.6.36 and .38 kernel, though not in the .34.  Here is the .36
>>> diff:
>
>>
>> Hello,
>>
>> There have been recent patches for igb that I submitted that might
>contain the fix you found in the out-of-tree driver, although I'm not
>sure which one would affect rx CRC errors.  Were there other symptoms?
>Any messages in the log?  I'll look through the patches and see if there
>is anything obvious and get you some commit numbers to try.
>
>There was nothing else that I noticed.  If your patches are in 2.6.39-
>rc4+, I can try
>them there perhaps?
>
>Thanks,
>Ben
>
>
>--
>Ben Greear <greearb@candelatech.com>
>Candela Technologies Inc  http://www.candelatech.com


Hello,

I'm sorry for the delay in responding.  I'm really scratching my head on this one as we don't do much in the driver that affects what we get on receive.  I've seen situations where some switches end up transmitting more of these and then we record more of them, but I'm guessing you're testing with the same equipment, just a different driver version.  Let me know if I'm mistaken there.  

So, to answer your question, I believe my patches are there, but I did review them again and I'm not sure they will make any difference.  My latest batch of patches was to add features to the i350 device specifically.

Give it try though and let me know if you see any difference with 2.6.39-rc4+.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation



