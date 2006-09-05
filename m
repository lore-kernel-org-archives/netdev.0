From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: e1000 Detected Tx Unit Hang
Date: Tue, 5 Sep 2006 09:09:43 -0700
Message-ID: <4807377b0609050909v59c1ad87jc4ef08ba1f4453d2@mail.gmail.com>
References: <002c01c6ce9d$a1cf9100$3224050a@avilespaxp>
	 <4807377b0609031045w67f70a3ese6bea93c15f75ba2@mail.gmail.com>
	 <000d01c6cfb1$f0d26880$3224050a@avilespaxp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:63836 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S965141AbWIEQJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 12:09:45 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1261762nfa
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2006 09:09:43 -0700 (PDT)
To: "Paul Aviles" <paul.aviles@palei.com>
In-Reply-To: <000d01c6cfb1$f0d26880$3224050a@avilespaxp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/3/06, Paul Aviles <paul.aviles@palei.com> wrote:
> Hey Jesse, thanks for your reply. Here is the stuff on /procs. The weird
no problem,

> part is that I have several other identical systems and only one is
> affected. Today I moved the hard drive to another similar system and I am
> not seeing the problem so I am wondering if is something maybe wrong with
> the card eeprom? Is there a way to check that?

I doubt it is an eeprom problem.  you can dump the eeproms with
ethtool -e eth0 from both machines and compare them .  Odd that only
one system is having the problem.  Could it be that the hardware on
that box is having issues?  Are you sure the machines are running the
same bios version with the same settings?  Any overclocking?

>  cat /proc/interrupts
>            CPU0       CPU1
>  16:      70540          0   IO-APIC-level  uhci_hcd:usb4, eth0

this could contribute to your problem, were you able to test without NAPI?

Jesse
