From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9][pull request] Complete drivers/net/ move
Date: Tue, 23 Aug 2011 15:41:57 -0700 (PDT)
Message-ID: <20110823.154157.105644491350157006.davem@davemloft.net>
References: <1314089149-27205-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958Ab1HWWmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 18:42:00 -0400
In-Reply-To: <1314089149-27205-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 23 Aug 2011 01:45:40 -0700

> The following series moves the FDDI, PPP, HIPPI, PLIP, SLIP and the cleanup
> of the drivers/net/ Kconfig & Makefile's.  This series in addition moves
> the 2 remaining drivers in drivers/net/pcmcia/ into their respective
> directories (arcnet & tokenring).  The last remaining change is to
> make the all the "new" Kconfig options introduced by the Ethernet
> drivers move to yes, so that current defconfig's will compile the expected
> drivers.
> 
> The following are changes since commit ca1ba7caa68520864e4b9227e67f3bbc6fed373b:
>   Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/next-organize master

I pulled this, but because you changed FDDI and these other newly
moved subsystems from a "config FOO" into a "menuconfig FOO", it now
prompts for those too during the first oldconfig.

As a result, I'm pretty sure people are going to lose drivers from
their build for exactly for the same reasons as the ethernet driver
issue you're trying to address in patch #9.
