From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [bisected] Weird sysctl regression
Date: Sat, 23 Aug 2008 18:03:33 +0200
Message-ID: <87wsi7en1m.fsf@natisbad.org>
References: <87fxoyal9j.fsf@natisbad.org>
	<20080823084936.GK28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:44391 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473AbYHWQYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Aug 2008 12:24:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Al Viro <viro@ZenIV.linux.org.uk> writes:

> On Thu, Aug 21, 2008 at 09:18:48AM +0200, Arnaud Ebalard wrote:
>> Hi,
>> 
>> While updating some IPv6-related patches for net-2.6, I hit the
>> following issue on a test laptop (G4-based 12" powerbook). After
>> compiling current net-2.6 kernel on another ppc device (G4-based 15"
>> powerbook), I have the same issue. Note that:
>> 
>> - it never shows up on any of the x86 devices I have.
>> - hardware of both ppc devices are similar (bcm4306, sungem, ...)
>>   i.e. they do not only have endianness in common (and i had no sparc
>>   device to test if it is an endianness issue or a coincidence)
>  
> Endianness is very unlikely to be the cause of that.

Hence the note on hardware similarities of both device outside
endianness. 

> Order of initialization, OTOH... 

+1

> Can you reproduce it on mainline kernel

All Linux 2.6.26 (initial and stable releases) are not affected. I am
currently running 2.6.26.3.

> or bisect between the mainline and net-2.6 if mainline is OK?

As I wrote in my previous email, bisecting net-2.6 lead me to 
9043476f726802f4b00c96d0c4f418dde48d1304 ([PATCH] sanitize proc_sysctl)
which is in the middle of a set of fs/sysctl related patches. 

I think I am missing the point on what you want me to do. Can you
clarify? 

Thanks for your work.

Cheers,

a+
