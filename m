From: Kumar Gala <kumar.gala@freescale.com>
Subject: Re: [PATCH] gianfar: Omit TBI auto-negotiation based on device tree
Date: Mon, 3 Nov 2008 14:38:15 -0600
Message-ID: <5F0C4A97-EA35-4235-9457-FC44D4906E2D@freescale.com>
References: <1225234382-23050-1-git-send-email-ncase@xes-inc.com> <Pine.LNX.4.64.0810301738020.3943@t2.domain.actdsltmp> <1225738532.27415.237.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Trent Piepho <tpiepho@freescale.com>, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:38597 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755AbYKCUib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 15:38:31 -0500
In-Reply-To: <1225738532.27415.237.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Nov 3, 2008, at 12:55 PM, Nate Case wrote:

> On Thu, 2008-10-30 at 18:07 -0700, Trent Piepho wrote:
>> But more relevant to your serdes problem, I also have a patch that
>> prevents
>> restarting serdes auto-negotiation if the serdes link is already up.
>> My SGMII
>> PHY will auto-negotiate, but it takes about 3 seconds.  Avoiding an
>> unnecessary 3 second auto-negotiation when the gianfar device is
>> opened lets
>> me cut my power-on to DHCP completion time in half.
>>
>> I wonder if this would also fix your problem, without needing to add
>> the extra
>> workaround?
>
> I just verified that your patch solves my problem without the need for
> my workaround.  So at this point, it looks like we can drop this patch
> ("Omit TBI auto-negotiation based on device tree").
>
> I tested when booting the kernel in U-Boot both via both TFTP and  
> flash
> (I was worried that your patch may only fix things for the TFTP boot
> case, but that wasn't the case fortunately).
>
> Thanks for the patch!

Ok, marked Nate's patch as superseded in patchworks.

- k
