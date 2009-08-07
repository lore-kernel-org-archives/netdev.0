From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: 2.6.31-rc5-git2 crash [net/core/flow.c:flow_cache_new_hashrnd]
Date: Thu, 6 Aug 2009 22:54:54 -0400
Message-ID: <20090807025454.GL3095@hansolo.jdub.homelinux.org>
References: <4A78292A.5000607@in.ibm.com> <4A783B1F.7000602@in.ibm.com> <1249395350.8016.5.camel@concordia> <1249597385.24311.10.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michael@ellerman.id.au, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:62259 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754AbZHGCy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 22:54:58 -0400
Received: by gxk9 with SMTP id 9so1716417gxk.13
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2009 19:54:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1249597385.24311.10.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 07, 2009 at 08:23:05AM +1000, Benjamin Herrenschmidt wrote:
>On Wed, 2009-08-05 at 00:15 +1000, Michael Ellerman wrote:
>
>> > c000000000600000  00001010      .long 0x1010
>> > 0:mon>
>> > c000000000600004  00000008      .long 0x8
>> > c000000000600008  00001013      .long 0x1013
>> > c00000000060000c  0000000f      .long 0xf
>> > c000000000600010  7961626f      rldimi. r1,r11,44,41
>> > c000000000600014  6f740000      xoris   r20,r27,0
>> > c000000000600018  00101600      .long 0x101600
>> > c00000000060001c  00000c00      .long 0xc00
>> > c000000000600020  00000400      .long 0x400
>> > c000000000600024  00101100      .long 0x101100
>> > c000000000600028  000008e9      .long 0x8e9
>
>BTW. Corruption looks like bi_recs... ie, broken yaboot. This was fixed
>recently, yaboot would eventually crap over the kernel for certain sizes
>of the kernel image.
>
>0x1010 = BI_FIRST
>0x1013 = BI_BOOTLOADER_ID followed by 0x7961626f6f74 which is
>"yaboot" :-)
>0x1016 = BI_MACHTYPE

I know we fixed it in Fedora for F11/F12.  Did it get fixed upstream?

josh
