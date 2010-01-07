From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 1/7] MIPS: Octeon: Fix EIO handling.
Date: Thu, 7 Jan 2010 13:59:50 -0800
Message-ID: <20100107215950.GA24672@suse.de>
References: <4B463005.8060505@caviumnetworks.com> <1262891106-32146-1-git-send-email-ddaney@caviumnetworks.com> <4B4645EE.5050302@ru.mvista.com> <4B464977.2090801@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, ralf@linux-mips.org,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37165 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754337Ab0AGWQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 17:16:35 -0500
Content-Disposition: inline
In-Reply-To: <4B464977.2090801@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2010 at 12:52:07PM -0800, David Daney wrote:
> Sergei Shtylyov wrote:
>> Hello.
>>
>> David Daney wrote:
>>
>>> If an interrupt handler disables interrupts, the EOI function will
>>> just reenable them.  This will put us in an endless loop when the
>>> upcoming Ethernet driver patches are applied.
>>>
>>> Only reenable the interrupt on EOI if it is not IRQ_DISABLED.  This
>>> requires that the EIO function be separate from the ENABLE function.
>>> We also rename the ACK functions to correspond with their function.
>>>
>>> Signed-off-by: David Daney <ddaney@caviumnetworks.com>
>>>   
>>
>>   I guess the subject should read "EIO", not "EIO"...
>>
>
> Indeed.  The compiler didn't catch that one.
>
> Perhaps Ralf can fix it if he merges it, otherwise I can resubmit with 
> corrected spelling.

I can change it when merging, don't worry about it.

thanks,

greg k-h
