From: "Paul Aviles" <paul.aviles@palei.com>
Subject: Re: e1000 Detected Tx Unit Hang
Date: Sun, 3 Sep 2006 19:37:38 -0400
Message-ID: <000d01c6cfb1$f0d26880$3224050a@avilespaxp>
References: <002c01c6ce9d$a1cf9100$3224050a@avilespaxp> <4807377b0609031045w67f70a3ese6bea93c15f75ba2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl-7-36.cofs.net ([68.142.7.36]:31810 "EHLO www.palei.com")
	by vger.kernel.org with ESMTP id S932164AbWICXho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2006 19:37:44 -0400
To: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Jesse, thanks for your reply. Here is the stuff on /procs. The weird 
part is that I have several other identical systems and only one is 
affected. Today I moved the hard drive to another similar system and I am 
not seeing the problem so I am wondering if is something maybe wrong with 
the card eeprom? Is there a way to check that?

Regards,

Paul

 cat /proc/interrupts
           CPU0       CPU1
  0:    7716253          0    IO-APIC-edge  timer
  3:      11538          0    IO-APIC-edge  serial
  8:          1          0    IO-APIC-edge  rtc
  9:          0          0   IO-APIC-level  acpi
 14:      93406          0    IO-APIC-edge  ide0
 16:      70540          0   IO-APIC-level  uhci_hcd:usb4, eth0
 17:          2          0   IO-APIC-level  ehci_hcd:usb1
 18:          0          0   IO-APIC-level  uhci_hcd:usb2, uhci_hcd:usb5
 19:         90          0   IO-APIC-level  uhci_hcd:usb3
NMI:          0          0
LOC:    7715839    7715838
ERR:          0
MIS:          0

----- Original Message ----- 
From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
To: "Paul Aviles" <paul.aviles@palei.com>
Cc: <netdev@vger.kernel.org>
Sent: Sunday, September 03, 2006 1:45 PM
Subject: Re: e1000 Detected Tx Unit Hang


> On 9/2/06, Paul Aviles <paul.aviles@palei.com> wrote:
>> I am getting "e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang" 
>> using
>> stock 2.6.17.11, 2.6.17.5 or 2.6.17.4 kernels on centos 4.3.
>>
>>  The server is a Tyan GS12 ( 82541GI/PI and 82547GI) and is connected to 
>> a
>> Netgear GS724T Gig  switch. I can easily reproduce the problem by trying 
>> to
>> do a large ftp transfer to the server. It does not happen if the server 
>> is
>> connected to a dummy 100 Mb switch, only when is connected to the Gig
>> switch.
>> I have also tried the options line below disabling tso, tx and rx in the
>> modprobe.conf without any luck.
>
> Hi Paul, sorry to hear about your problem.  You're getting hangs on
> the 82547 right?  can you send the output of cat /proc/interrupts.
> I'm curious if you are sharing interrupts while running NAPI.
>
> Also, please try the driver without CONFIG_E1000_NAPI enabled in your
> kernel .config, and let us know the results.
>
> Someone has posted (what they think is) a theoretical problem with
> irq_sem on the 82547 at e1000.sf.net and I haven't had a chance to
> figure it out yet.
>
> Jesse
>
> -- 
> VGER BF report: U 0.495355
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> 



-- 
VGER BF report: U 0.516297
