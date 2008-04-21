From: speedy <speedy@3d-io.com>
Subject: Re[2]: [BUG REPORT, 2.6.22] e1000: detected tx unit hang
Date: Mon, 21 Apr 2008 23:56:57 +0200
Message-ID: <304359202.20080421235657@3d-io.com>
References: <1071646044.20080421225227@3d-io.com> <480D0ADB.9000308@intel.com>
Reply-To: speedy <speedy@3d-io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vwp1316.webpack.hosteurope.de ([87.230.105.72]:37708 "EHLO
	vwp1316.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753335AbYDUV47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 17:56:59 -0400
In-Reply-To: <480D0ADB.9000308@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Auke,

Monday, April 21, 2008, 11:44:59 PM, you wrote:

KA> [dropped lkml from the Cc]

KA> speedy wrote:
>> Hello Linux crew,
>> 
>>         I've just switched the
>> 
>>         Ethernet controller: Intel Corporation 82545GM Gigabit Ethernet Controller (rev 01)
>> 
>>         netword card to an NForce 2 based motherboard and after a day
>>         of work it got stuck with "detected tx unit hang" messages
>>         showing in the console.
>> 
>>         The card worked flawlessly under load in a different computer
>>         for two years now, under the same/similar Ubuntu operating system.
>> 
>>         /var/log/messages:  http://87.230.23.147/messages.txt
>>         /proc/interrupts: http://87.230.23.147/proc_interrupts.txt
>>         lspci -vv: http://87.230.23.147/lspcivv.txt
>> 
>> 
>>         If more info is needed, let me know.


KA> basically it's inserted into a new motherboard?

Yup.

I've changed the PCI slot in which the card is inserted (just out of
hunch) and rebooted the server. I'll let you know if the problem
happens again.

KA> what was the old motherboard?

QDI Legend KinetiZ 7B

http://www.qdigrp.com/qdisite/eng/products/K7B.htm

(had uptimes of 200+ days :)

KA> can you check the BIOS and disable things like "PCI Write combining" or
KA> "Writeback" or any option looking similar to that?

I'm curious to see how often does the problem happen. I'll try such
measures if it reproduces itself.

KA> It appears you hit an issue that is exposed by these adapters on some AMD/NVIDIA
KA> chipset-based motherboards. This issue is known and we are investigating this and
KA> have been for a long time. The root cause is still yet unknown however.

Does it also happen with newer AMD/NVIDIA motherboards? :(

KA> For some people disabling TSO helps to relieve the situation. You could give that
KA> a try.

TSO? What is that and how to disable it? :)

KA> Cheers,

KA> Auke

Thanks!


-- 
Best regards,
 speedy                            mailto:speedy@3d-io.com

