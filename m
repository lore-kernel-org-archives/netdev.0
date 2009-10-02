From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: Re: Messages are printed on screen
Date: Fri, 02 Oct 2009 14:01:09 +0200
Message-ID: <ha4q26$7mt$1@ger.gmane.org>
References: <ha4igd$ghh$1@ger.gmane.org> <1254480996.23350.73.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:44403 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753625AbZJBMBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 08:01:32 -0400
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1MtgpL-0004re-Is
	for netdev@vger.kernel.org; Fri, 02 Oct 2009 14:01:35 +0200
Received: from dslb-092-076-255-225.pools.arcor-ip.net ([92.76.255.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 14:01:35 +0200
Received: from feldmann_markus by dslb-092-076-255-225.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2009 14:01:35 +0200
In-Reply-To: <1254480996.23350.73.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings schrieb:
> On Fri, 2009-10-02 at 11:52 +0200, Markus Feldmann wrote:
>
>>
>> As you see some of my IRQ-Lines are multiply in use, so my Server is 
>> working hard at his limit.
> 
> IRQ sharing is normal on PCs without MSI support, but to see where
> that's happening you need to look at /proc/interrupts and not the BIOS
> setup program or wherever you got the above information from.
Ok i did <cat /proc/interrupts> and got:
            CPU0
   0:     259603    XT-PIC-XT        timer
   1:       1421    XT-PIC-XT        i8042
   2:          0    XT-PIC-XT        cascade
   4:     200000    XT-PIC-XT        ohci_hcd:usb3, pppp0
   5:          0    XT-PIC-XT        ehci_hcd:usb1, lan0
   7:       6959    XT-PIC-XT        lan1
   8:          2    XT-PIC-XT        rtc0
   9:          0    XT-PIC-XT        acpi
  11:      37697    XT-PIC-XT        ide2, ide3, ohci_hcd:usb2, lan2
  14:          0    XT-PIC-XT        ide0
NMI:          0   Non-maskable interrupts
TRM:          0   Thermal event interrupts
MCE:          0   Machine check exceptions
MCP:         13   Machine check polls
ERR:          2

How can i assigned IRQs during Boot?

How can i watch which IRQ Line has most traffic or problems ?

>> The result is sometimes freezing of my 
>> Server, especially if there is much processing on these devices. I 
>> remember that with Kernel 2.6.18 my system didn't does freezing.
> 
> This is simply a bug, not a result of IRQ sharing or 'working hard'.
But something had initiated this freezing. Although i do not know the 
Bug, i should be able to avoide this Problem by do some prevention ?!

> 
>> How can i disable the output of messages (about dropped packets from my 
>> firewall) to my terminal ?
> 
> Edit the value of kernel.printk in /etc/sysctl.conf.
Ok i did add:
kernel.printk= 4 4 1 7
to </etc/sysctl.conf>
> 
>> How can i stabilize my IRQ-System with the kernel 2.6.31.1 ?
> 
> I would expect the standard kernel version for 'lenny' or the 2.6.30
> kernel from 'sid' to be more stable.
Ok i will try the kernel from Debian Sid. :-)
> 
>> What debug features should i disable ?
> 
> No idea, you didn't even specify what you enabled...
I will add some enabled features next week.

regards Markus

