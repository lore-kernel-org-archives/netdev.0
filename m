From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Centrino wireless review
Date: Tue, 09 Mar 2004 21:47:59 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404E81DF.9020400@pobox.com>
References: <404E3DB8.1000000@pobox.com> <404E795A.9050906@linux.co.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.co.intel.com>
In-Reply-To: <404E795A.9050906@linux.co.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Ketrenos wrote:
> Jeff Garzik wrote:
> 
>>
>> Thanks much to you and Intel for publishing this!
> 
> 
> Wow.  Quick review turn around :)

I've been hoping a Centrino wireless driver would appear for a while now ;-)


>> 0) is the firmware blob truly a firmware blob, and not an x86 ELF 
>> blob?  In other words, will this firmware work on non-x86?
> 
> 
> The firmware data is just loaded from disk and handed off to the ipw2100 
> hardware; no linking with the kernel or running on the CPU.  To make 
> firmware loader work on an architecture w/ endian issues would require 
> some tweaks, but the firmware image itself wouldn't change (none of it 
> is executed by the CPU)
> 
> Or am I missing what you're asking?

Nope, that answered my question.  Thanks.


>> 24) I don't see that you need to list all 1001 (or so:)) PCI subsystem 
>> vendor ids...  just list the PCI vendor and device id.  (unless I'm 
>> missing something?)
> 
> 
> Apparently we have other cards that match the PCI vendor and device, but 
> are not IPW 2100[A]s, so the subsystem ids had to be added.

Sigh.


>> 26) I'm curious, what is the locking/exclusion on the ipw2100_wx_xxx() 
>> functions?
> 
> 
> Locking is lacking in a few places in the wx code.  Any data that needs 
> to be protected will end up being wrapped with the priv->low_lock 
> spinlock.  Is there something you saw in how we have it that might be 
> problematic?

In general I saw a lack of locking in the wx module, but I admit I could 
have missed these low_lock uses.

	jeff
