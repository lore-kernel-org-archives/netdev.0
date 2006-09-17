From: "Paul Aviles" <paul.aviles@palei.com>
Subject: Re: e1000 Detected Tx Unit Hang
Date: Sat, 16 Sep 2006 22:05:47 -0400
Message-ID: <000301c6d9fd$ca77a5f0$3224050a@avilespaxp>
References: <002c01c6ce9d$a1cf9100$3224050a@avilespaxp> <4807377b0609031045w67f70a3ese6bea93c15f75ba2@mail.gmail.com> <000d01c6cfb1$f0d26880$3224050a@avilespaxp> <4807377b0609050909v59c1ad87jc4ef08ba1f4453d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl-7-36.cofs.net ([68.142.7.36]:16195 "EHLO www.palei.com")
	by vger.kernel.org with ESMTP id S964906AbWIQCFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2006 22:05:53 -0400
To: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>,
	<netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse, today the server froze and was not able to see anything in the logs. 
Nothing at all about any error, just plain froze.  Just in case, this is a 
different unit altogether, still the same model as the units having the Tx 
Unit Hang, but different memory, motherboard and CPU. The only 1 thing that 
is the same is the hard drive a regular IDE...

The only one thing I noticed that is very weird to me at least is that in 
powering off the unit from the crash and rebooting it I saw some lines like 
this in the logs..

Sep 16 11:08:03 www kernel: checking if image is initramfs... it is
Sep 16 07:05:19 www sysctl: kernel.msgmnb = 65536

The odd part is the diff in the time stamps between one entry and the very 
next one in the log. Any ideas what can cause this? Also, any way to get a 
dump or some way to prevent the system from locking without any log entries?

Regards,

Paul

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
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> 


