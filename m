From: Ben Greear <greearb@candelatech.com>
Subject: Re: Regression on VIA C3 motherboard, commit: 66f2173e2
Date: Fri, 06 Feb 2009 11:20:08 -0800
Message-ID: <498C8D68.3040504@candelatech.com>
References: <498A93E5.2080509@candelatech.com> <alpine.LFD.2.00.0902061350470.26256@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, linux-acpi@vger.kernel.org
To: Len Brown <lenb@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55937 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753489AbZBFTUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 14:20:12 -0500
In-Reply-To: <alpine.LFD.2.00.0902061350470.26256@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Len Brown wrote:
> Thanks for the bisect, Ben.
> 
> Please test the patch below.
> 
> I assume even without the patch, booting with "acpi=off" on your
> BIOS-ACPI-disabled box works?  (if no, this patch will not solve
> all your problems, for you have additional trouble elsewhere)
> 
> I am curious why you're running a CONFIG_ACPI=y kernel
> for a box with ACPI disabled. (though yes, it is supposed to work)
> 
> I'm even more curious what bad things happen when
> you enable ACPI in the BIOS -- can you let me know
> and we can try to fix them so the machine can run as shipped?

At one time, these boxes would actually burn out their power
supply if you did an 'init 0' with the BIOS configured to
shut down the system.  It would just suck more and more power
(we measured) until the brick smoked, and the motherboard components
got very hot as well.  I think we were just lucky that the PS died
before the MB did.

This was a while back, but I believe part of the fix was to disable
ACPI so the system couldn't possibly try to power itself down
in this manner.

I will try your patch, but I'm about to go off for a ~2week vacation,
so I probably won't have time to test enabling ACPI and/or compiling
a kernel w/out it to see what shakes out.

I re-worked my previous patch per Ingo's suggestion and am
about to send it off..but please feel free to NAK it if you
think it's wrong.  I don't really know enough about this area
to argue one way or another.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

