From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re: [PATCH  kernel 2.6.32-rc5] pcnet_cs: add cis of PreMax PE-200
 ethernet pcmcia card
Date: Sun, 25 Oct 2009 11:10:00 +0900
Message-ID: <20091025111000.2d97e595.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg501.nifty.com ([202.248.238.81]:46658 "EHLO
	userg501.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbZJYCKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 22:10:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>> > Random question: are CIS files copyrightable?  
>> 
>> The CIS contains the IRQ, ioport-range, voltage information etc
>> like the PCI config space.
>> So I think it is not copyrightable.
>> but Sierra Wireless provided this CIS by GPL.
>[...]

>If it is subject to copyright - which apparently they think it is - then
>when redistributing under GPL we must be able to provide the 'preferred
>form for modification'.  So that leads to the question, is this blob or
>hex file the preferred form?


(1)The CIS contains data only,
    does not contain the code to be executed.
(2)Sierra Wireless provided the binary of the CIS only.
(3)These CIS are stable and does not need to be modified.
(3)The content of the CIS can be seen by the dump_cis utility.

So if someone want to modify the CIS , I think it is OK
to use hex editor.

Best Regards
Ken

