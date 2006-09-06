From: "Paul Aviles" <paul.aviles@palei.com>
Subject: Re: e1000 Detected Tx Unit Hang
Date: Tue, 5 Sep 2006 21:33:10 -0400
Message-ID: <002501c6d154$69d7b480$3224050a@avilespaxp>
References: <002c01c6ce9d$a1cf9100$3224050a@avilespaxp> <4807377b0609031045w67f70a3ese6bea93c15f75ba2@mail.gmail.com> <000d01c6cfb1$f0d26880$3224050a@avilespaxp> <4807377b0609050909v59c1ad87jc4ef08ba1f4453d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl-7-36.cofs.net ([68.142.7.36]:13407 "EHLO www.palei.com")
	by vger.kernel.org with ESMTP id S932209AbWIFBdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2006 21:33:18 -0400
To: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I haven't done the NAPI yet. These are identical systems altogether, maybe 
the CPU is a different stepping at the most, but that is all.
The "16:      70540          0   IO-APIC-level  uhci_hcd:usb4, eth0" is the 
same in every GS12 I have. No overclocking and same BIOS. Tyan released  ver 
1.8 about a month ago and I did the upgrade and same effect. Then I thought 
about upgrading to 2.6.17.11 just to see if the driver will have any issues 
and nothing, same deal. The only way I was able to control it was usign a 
dummy 10/100 non-management switch. Then we had no issues.

I will try without NAPI tomorrow 9-6-06 and will report back. My 
understanding on NAPI was that it will drop packets by design on overload. 
Why will that cause a system lock?

Are there any other kernel options you would like to enable to track this 
better and if you need remote access to the system I can accomodate too, 
just let me know what time zone you are to schedule it. Let me know.

Regards,

Paul Aviles

----- Original Message ----- 
From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
To: "Paul Aviles" <paul.aviles@palei.com>
Cc: <netdev@vger.kernel.org>
Sent: Tuesday, September 05, 2006 12:09 PM
Subject: Re: e1000 Detected Tx Unit Hang


> On 9/3/06, Paul Aviles <paul.aviles@palei.com> wrote:
>> Hey Jesse, thanks for your reply. Here is the stuff on /procs. The weird
> no problem,
>
>> part is that I have several other identical systems and only one is
>> affected. Today I moved the hard drive to another similar system and I am
>> not seeing the problem so I am wondering if is something maybe wrong with
>> the card eeprom? Is there a way to check that?
>
> I doubt it is an eeprom problem.  you can dump the eeproms with
> ethtool -e eth0 from both machines and compare them .  Odd that only
> one system is having the problem.  Could it be that the hardware on
> that box is having issues?  Are you sure the machines are running the
> same bios version with the same settings?  Any overclocking?
>
>>  cat /proc/interrupts
>>            CPU0       CPU1
>>  16:      70540          0   IO-APIC-level  uhci_hcd:usb4, eth0
>
> this could contribute to your problem, were you able to test without NAPI?
>
> Jesse
>
> 


