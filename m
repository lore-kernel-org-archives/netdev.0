From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 01/10] smc91x: remove unused code enclosed by #ifdef CONFIG_ISA
 .. #endif
Date: Fri, 27 Jun 2008 02:31:40 -0400
Message-ID: <4864894C.8040508@garzik.org>
References: <> <1214300867-15495-2-git-send-email-eric.y.miao@gmail.com> <486480E6.8070804@garzik.org> <48648467.1080308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>,
	Nicolas Pitre <nico@cam.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50032 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753636AbYF0Gbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 02:31:44 -0400
In-Reply-To: <48648467.1080308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Miao wrote:
> Jeff Garzik wrote:
>> Eric Miao wrote:
>>> Apparently, the code enclosed by #ifdef CONFIG_ISA .. #endif are no
>>> longer
>>> used
>> What does this mean?
>>
>> CONFIG_ISA platforms still exist, and one presumes that the ISA hardware
>> still exists.
>>
>> Is this hardware covered by another driver?
>>
> 
> Well, I assume the original code tends to support ISA with module
> parameters to setup the IO address base and IRQ etc. But obviously,
> those part of the code is now totally invalid and confusing only.
> 
> Should there be requirement of supporting ISA hardware with this
> chip, the driver is actually unable to, and I prefer to re-write
> that part of the code if necessary.
> 
> BTW: I don't know any ISA NIC with a SMC91X chip by far, and I
> cannot infer by the driver code itself what type of ISA NIC it
> is supporting.

These are questions that must be researched...

Where did the ISA support come from?

Was it copied from another driver, or did it actually work on real 
hardware at some point in the past?

If the latter, when did ISA support stop working?  i.e. a regression 
occurred

Certainly if the driver has -never- worked on ISA hardware, then the 
code should be removed.  Who knows the definitive answer?  What does the 
driver look like in older (pre-2.6.12) kernels?

	Jeff



