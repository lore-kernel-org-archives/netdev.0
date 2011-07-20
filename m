From: Danie Wessels <dawessels@telkomsa.net>
Subject: Re: NIC driver r8168 with r8169 for RTL8111/8168B and DGE-528T together
Date: Thu, 21 Jul 2011 00:11:46 +0200
Message-ID: <4E2752A2.3030208@telkomsa.net>
References: <4E26B198.4020606@telkomsa.net> <20110720122206.73898673@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrba-ip-smtp-1-4.saix.net ([196.25.240.238]:41131 "EHLO
	rrba-ip-smtp-1-4.saix.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691Ab1GTWKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 18:10:48 -0400
In-Reply-To: <20110720122206.73898673@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/20/2011 09:22 PM, Stephen Hemminger wrote:
> On Wed, 20 Jul 2011 12:44:40 +0200
> Danie Wessels<dawessels@telkomsa.net>  wrote:
>
>> I would like to use my onboard NIC (eth0) with its r8168 driver from
>> RealTek together with my D-Link NIC (eth4=eth1) with its r8169 default
>> driver from the install.
>
> The kernel developers do not support the use of out of tree
> vendor drivers. If there is some reason the default kernel driver does
> not work for your hardware, that is a bug that should be reported and
> it will get fixed.
>
I understand from Ubuntu forum that this bug (#347711) with the r8169 
driver for the RTL8111/8168B is in the Will-not-fix state due to 
(hardware?) it not being supported any more.
That leaves a number of us with little options.

.> Remove the 8168 PCI IDs from the r8169 driver and you should be set.
gr8. I can give that a try...8^0  (some more hints....?)

.>It ought to be supported by the kernel r8169 driver.

See bugs listed on Ubuntu:
https://bugs.launchpad.net/ubuntu/+source/linux-source-2.6.22/+bug/141343
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/221499
https://bugs.launchpad.net/linux/+bug/347711

And 0n Bug #347711
linux-kernel-bugs #12411
Duplicates of this bug
Bug #76489
Bug #347670

.> Which problem(s) do you have with it ?
No communication to outside devices. I can not ping my router through it 
but can ping its IP.


What can I do now or where should I report it or how can I help?
RTFM 4 rules.d = where?
-- 
Dankie
Danie Wessels
