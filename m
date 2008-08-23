From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [bisected] Weird sysctl regression
Date: Sat, 23 Aug 2008 09:49:36 +0100
Message-ID: <20080823084936.GK28946@ZenIV.linux.org.uk>
References: <87fxoyal9j.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:47330 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbYHWIti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 04:49:38 -0400
Content-Disposition: inline
In-Reply-To: <87fxoyal9j.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 09:18:48AM +0200, Arnaud Ebalard wrote:
> Hi,
> 
> While updating some IPv6-related patches for net-2.6, I hit the
> following issue on a test laptop (G4-based 12" powerbook). After
> compiling current net-2.6 kernel on another ppc device (G4-based 15"
> powerbook), I have the same issue. Note that:
> 
> - it never shows up on any of the x86 devices I have.
> - hardware of both ppc devices are similar (bcm4306, sungem, ...)
>   i.e. they do not only have endianness in common (and i had no sparc
>   device to test if it is an endianness issue or a coincidence)
 
Endianness is very unlikely to be the cause of that.  Order of initialization,
OTOH...

Can you reproduce it on mainline kernel or bisect between the mainline
and net-2.6 if mainline is OK?
