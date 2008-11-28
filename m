From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Fri, 28 Nov 2008 12:36:31 -0600
Message-ID: <20081128123631.5209d0b8@osprey.hogchain.net>
References: <492DD792.6080302@linux.intel.com>
	<20081128111827.79b12739@osprey.hogchain.net>
	<20081128093217.3888fb46@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:32606 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752503AbYK1Sgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 13:36:38 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1468102rvb.1
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2008 10:36:37 -0800 (PST)
In-Reply-To: <20081128093217.3888fb46@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Nov 2008 09:32:17 -0800
Arjan van de Ven <arjan@linux.intel.com> wrote:


> to be specific in counts, the data I have so far is:
> 
>  count |           guilty           
> -------+----------------------------
>   1599 | dev_watchdog(sis900)
>   1501 | dev_watchdog(r8169)
>    280 | dev_watchdog(via-rhine)
>    264 | dev_watchdog(cdc_ether)
>    213 | dev_watchdog(usbnet)
>    192 | dev_watchdog(8139too)
>    164 | dev_watchdog(8390)
>    158 | dev_watchdog(via_rhine)
>    129 | dev_watchdog(ne2k-pci)
>    122 | dev_watchdog(atl1)
>    102 | dev_watchdog(atl2)
>    101 | dev_watchdog(orinoco)

> ATL1 isn't doing all that bad in this
> regard, although your driver is still a little higher than other
> popular cards like tg3, e1000, e1000e etc. 

...And that's what troubles me: the L1 chip isn't what I'd characterize
as "popular" -- it's LOM only, and it's found in only about 25
mainboards that I know of (from voluntary user reports) -- yet its
prevalence in the tx timeout list seems to be quickly rising.

Can you produce a list from your database for me that includes the
kernel version for each of the 122 reported atl1 dev_watchdog warnings?
I'd like to see if I can correlate an increase in the warnings with a
particular change we made.

Thanks.

Thanks.
