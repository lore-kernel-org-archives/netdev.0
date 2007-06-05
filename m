From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC VLAN 00/10]: VLAN netlink support try 2
Date: Tue, 05 Jun 2007 13:08:46 -0700
Message-ID: <4665C2CE.4050504@candelatech.com>
References: <20070605143650.23717.91261.sendpatchset@localhost.localdomain> <46658E84.1090301@candelatech.com> <4665AB57.7030605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:57310 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757201AbXFEUIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 16:08:54 -0400
In-Reply-To: <4665AB57.7030605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Ben Greear wrote:
>> Patrick McHardy wrote:
>>
>>> The last VLAN patchset was outdated, sorry about the mixup. These are the
>>> correct patches. The iproute patch I posted was correct, so no repost of
>>> that one.
>>>
>>>   
>> Is there any significant performance penalty in creating VLANs using
>> these patches?
>>
>> If you have a test station handy, could you let us know what 'time'
>> shows for a script
>> creating 4000 VLANs with the old vconfig/ioctl method v/s this new method?
> 
> 
> Not significantly more, for 1000 VLANs I get:
> 
> ip link add:
> 
> real    0m22.836s
> user    0m0.100s
> sys     0m5.850s
> 
> vconfig add:
> 
> real    0m19.739s
> user    0m0.090s
> sys     0m3.600s

Thanks for doing the tests.  That small performance drop seems
fine to me.

> ip -b (batch add):
> 
> real    0m5.239s
> user    0m0.280s
> sys     0m3.480s

And that looks quite interesting!

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

