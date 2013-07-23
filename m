From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [ethtool] Add new Realtek devices
Date: Tue, 23 Jul 2013 23:08:49 +0200
Message-ID: <12627856.YYxZYHakH8@al>
References: <3162188.mmLmSZRt9A@al> <20130723202544.GD31567@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:49110 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756516Ab3GWVIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 17:08:54 -0400
Received: by mail-we0-f170.google.com with SMTP id w60so1450596wes.1
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 14:08:52 -0700 (PDT)
In-Reply-To: <20130723202544.GD31567@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 23 July 2013 22:25:44 Francois Romieu wrote:
> Peter Wu <lekensteyn@gmail.com> :
> [...]
> 
> > sure what the cause is of this strange behavior. Francois, perhaps you
> > have an idea why reading in blocks of larger than 7 results in a error?
> 
> No but it has been seen before. Platform or device thing ?

What kind of devices were those? This issue occurs on an on-board PCIe chip 
where the memory is 64-bit, prefetchable. I have no issues with a PCI card, 
memory 32-bit, non-prefetchable.

PCI: RTL8168sb
PCIe: RTL8111E

Regards,
Peter
