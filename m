From: Daniel J Blueman <daniel@numascale-asia.com>
Subject: Re: BCM5709 hang and state dump...
Date: Thu, 07 Mar 2013 20:18:43 +0800
Message-ID: <513885A3.7050907@numascale-asia.com>
References: <5125B01E.4090405@numascale-asia.com> <1361483951.2240.44.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <5126D912.9000800@numascale-asia.com> <51386B82.5050900@numascale-asia.com> <1362654030.8980.62.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Steffen Persvold <sp@numascale.com>, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:60985 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756704Ab3CGMSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 07:18:47 -0500
Received: by mail-pb0-f41.google.com with SMTP id um15so343810pbc.0
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 04:18:47 -0800 (PST)
In-Reply-To: <1362654030.8980.62.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2013 07:00 PM, Michael Chan wrote:
> On Thu, 2013-03-07 at 18:27 +0800, Daniel J Blueman wrote:
>> We've hit this again [1], with 3.8.0 this time. Any success on the debug
>> patches?
>
> I have 2 suggestions at this point:
>
> 1. Some users who report similar issues say that upgrading the BIOS has
> fixed the issue.  So please try upgarding the BIOS if possible.
>
> 2. You can also disable MSIX and see if it runs any better.  Use sysfs
> to do that or simply use bnx2 parameter disable_msi=1.
>
> I suspect that some MSIX IRQ messages are not delivered to the CPU for
> some reason.  Please try one or both suggestions and let me know.

Yes, we're on the current of each available BIOS/firmware.

We'll move to APIC interrupts for the NIC and see how it goes over a few 
weeks, since it takes a while to occur.

Thanks again Michael!

Daniel
-- 
Daniel J Blueman
Principal Software Engineer, Numascale Asia
