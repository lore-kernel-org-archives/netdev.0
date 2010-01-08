From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-2.6 PATCH 1/5] e1000e: call pci_save_state() after
	pci_restore_state()
Date: Thu, 7 Jan 2010 23:59:32 -0800
Message-ID: <9929d2391001072359u499b3269v9b0c1cd6ca864798@mail.gmail.com>
References: <20100108023033.31476.4034.stgit@localhost.localdomain>
	 <20100107.235240.173918660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:41446 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848Ab0AHH7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 02:59:33 -0500
Received: by pwj9 with SMTP id 9so12524423pwj.21
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2010 23:59:32 -0800 (PST)
In-Reply-To: <20100107.235240.173918660.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 7, 2010 at 23:52, David Miller <davem@davemloft.net> wrote:
>
> Aren't the fragment overrun patches for e1000 and e1000e 1,000 times
> more important that thumb twiddling fixes like these? :-(
> --

I would agree, and Jesse's updated patches which were made 1 day ago
are currently under test and review, where as these patches were
produced over Christmas break and testing was completed before Jesse
completed his rework of the fragment overrun patches (and are based on
a driver which has these patches applied).

-- 
Cheers,
Jeff
