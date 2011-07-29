From: Sven Anders <anders@anduras.de>
Subject: Re: Realtek 8139 Flow Control?
Date: Fri, 29 Jul 2011 16:59:58 +0200
Message-ID: <4E32CAEE.1050104@anduras.de>
References: <4E2DC710.5000100@anduras.de> <4E3004BD.4090705@anduras.de> <20110728063526.GA11214@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000305060408070504090206"
Cc: netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailr01.anduras.de ([89.28.138.12]:42651 "EHLO
	mailr01.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789Ab1G2PAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 11:00:00 -0400
In-Reply-To: <20110728063526.GA11214@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000305060408070504090206
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Francois Romieu schrieb:
> Sven Anders <anders@anduras.de> :
>> Sven Anders wrote:
> [...]
>>> We have appliances with Realtek 8139C/8139C+ (rev 10) chipsets (with the
>>> PCI IDs: 10ec:8139). We are using the 8139too driver (version: 0.9.28)
> 
> The PCI revision ID is not incompatible with a 8139c(l)+. If so the 8139cp
> driver may prove easier to handle at the driver programming level. It's
> almost surely less commonly used though.
> 
> I'd suggest to use both PCI information and TxConfig content to identify
> Realtek's chipset. ethtool should provide the latter.
> 
>>> According the datasheet the chipset supports Flow Control (IEEE 802.3x).
>>>
>>> I want to know, if the support for enabling flow control is missing in
>>> the driver by purpose or is only not implemented due to lack of time?
> [...]
>> Can somebody of the old implementors please answer this question?
> 
> Hint ? :o)
> 
> This hardware is not exactly fun, especially if you do not own a c+ model
> (4 Tx descriptors, a single copy-only receive buffer, really cheap...).
> 
>> We need that feature and I'm willing to implement it, but I need the
>> confirmation, that it was not done due to lack of time and not because
>> will not work (correctly)...
> 
> If you do not get an answer and the relevant bit is already set in the
> eeprom, you should be able to make your own mind shortly. The comment
> in the datasheet rightfully reminds that both the NIC and the peer
> networking gear need to handle flow control correctly.

Thanks for the long and only answer (so far)!

But I still need the following statement before I implement it:


   [ ] It was not implemented, because I will not work!

   [ ] It was not implemented due to lack of time. It should work.


I want to know this, because I'm not eager to waste my time...

Regards
 Sven Anders

-- 
 Sven Anders <anders@anduras.de>                 () UTF-8 Ribbon Campaign
                                                 /\ Support plain text e-mail
 ANDURAS intranet security AG
 Messestrasse 3 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 50-55

Those who would give up essential Liberty, to purchase a little
temporary Safety, deserve neither Liberty nor Safety.
  - Benjamin Franklin

--------------000305060408070504090206
Content-Type: text/x-vcard; charset=utf-8;
 name="anders.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="anders.vcf"

begin:vcard
fn:Sven Anders
n:Anders;Sven
org:ANDURAS AG;Research and Development
adr;quoted-printable:;;Messestra=C3=9Fe 3;Passau;Bavaria;94036;Germany
email;internet:anders@anduras.de
title:Dipl. Inf.
tel;work:++49 (0)851 / 490 50 -0
tel;fax:++49 (0)851 / 590 50 - 55
x-mozilla-html:FALSE
url:http://www.anduras.de
version:2.1
end:vcard


--------------000305060408070504090206--
