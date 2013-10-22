From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/14][pull request] Intel Wired LAN Driver
 Updates
Date: Tue, 22 Oct 2013 15:53:36 -0400 (EDT)
Message-ID: <20131022.155336.2066350912394604583.davem@davemloft.net>
References: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59219 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754914Ab3JVTxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 15:53:38 -0400
In-Reply-To: <1382451757-9817-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 22 Oct 2013 07:22:23 -0700

> This series contains updates to i40e only.
> 
> Jesse provides 6 patches against i40e.  First is a patch to reduce
> CPU utilization by reducing read-flush to read in the hot path.  Next
> couple of patches resolve coverity issues reported by Hannes Frederic
> Sowa <hannes@stressinduktion.org>.  Then Jesse refactored i40e to cleanup
> functions which used cpu_to_xxx(foo) which caused a lot of line wrapping.
> 
> Mitch provides 2 i40e patches.  First fixes a panic when tx_rings[0]
> are not allocated, his second patch corrects a math error when
> assigning MSI-X vectors to VFs.  The vectors-per-vf value reported
> by the hardware already conveniently reports one less than the actual
> value.
> 
> Shannon provides 5 patches against i40e.  His first patch corrects a
> number of little bugs in the error handling of irq setup, most of
> which ended up panicing the kernel.  Next he fixes the overactive
> IRQ issue seen in testing and allows the use of the legacy interrupt.
> Shannon then provides a cleanup of the arguments declared at the
> beginning of each function.  Then he provides a patch to make sure
> that there are really rings and queues before trying to dump
> information in them.  Lastly he simplifies the code by using an
> already existing variable.
> 
> Catherine provides an i40e patch to bump the version.

Pulled, thanks Jeff.

Just a note for the future, and I decided not to push back this time when
I saw it in this series.  When you have a construct like:

	if (x)
		for( ... ) {
		}

Put the top-level condition in braces too as it's much easier to read
and audit:

	if (x) {
		for ( ... ) {
		}
	}

Thanks.
