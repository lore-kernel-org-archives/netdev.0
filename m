From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [2.6 patch] the scheduled eepro100 removal
Date: Fri, 30 Mar 2007 12:40:29 -0400
Message-ID: <460D3D7D.70702@tmr.com>
References: <36D9DB17C6DE9E40B059440DB8D95F5202357DB0@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roberto Nibali <ratz@drugphish.ch>,
	Yinghai Lu <yinghai.lu@amd.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Adrian Bunk <bunk@stusta.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tmr.com ([64.65.253.246]:53163 "EHLO gaimboi.tmr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753932AbXC3Qmg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 12:42:36 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F5202357DB0@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandeburg, Jesse wrote:
> Roberto Nibali wrote:
>   
>>>> Sounds sane to me.  My overall opinion on eepro100 removal is that
>>>> we're not there yet.  Rare problem cases remain where e100 fails
>>>> but eepro100 works, and it's older drivers so its low priority for
>>>> everybody. 
>>>>
>>>> Needs to happen, though...
>>>>         
>>> It seems that several Tyan Opteron base system that were using IPMI
>>> add on card.  the IPMI card share intel 100Mhz nic onboard. you need
>>> to use eepro100 instead of e100 otherwise the e100 will shutdown OOB
>>> (out of Band) connection for IPMI when shut down the OS.
>>>       
>> I find it hard to believe that something as common as IPMI in
>> conjunction with the IPMI technology wasn't tested in Intel's lab.
>> From my experience with Intel Server boards, onboard IPMI (all offered
>> versions) and e100/e1000 NICs, I've never ever experienced any
>> problems operating the BMC over the NIC. Also, I don't quite
>> understand you point about the "IPMI card sharing the 100Mbit/s NIC"
>> onboard? What exactly is shared?
>>     
>
> It's a legit problem, but only with this *one* system.
>
>   
Of course the eepro100 driver is not taking a lot of maintenance either, 
removing it is not critical as long as there is a legitimate need to 
support old hardware.

-- 
bill davidsen <davidsen@tmr.com>
  CTO TMR Associates, Inc
  Doing interesting things with small computers since 1979

