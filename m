From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: igb patches needed for stable
Date: Tue, 13 May 2014 09:59:49 +0200
Message-ID: <20140513095949.09333569@free-electrons.com>
References: <20140410143603.3df4f20c@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Pieper <jeffrey.e.pieper@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Christoph Paasch <christoph.paasch@uclouvain.be>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:35791 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752928AbaEMH7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 03:59:52 -0400
In-Reply-To: <20140410143603.3df4f20c@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, 10 Apr 2014 14:36:03 +0200, Thomas Petazzoni wrote:
> Hello,
> 
> I just wanted to let you know that the following two patches:
> 
>   cb06d102327eadcd1bdc480bfd9f8876251d1007 igb: Fix Null-pointer dereference in igb_reset_q_vector
>   b709323d2477614823a38c2f2a9a206e087e28fc igb: Unset IGB_FLAG_HAS_MSIX-flag when falling back to msi-only
> 
> should probably be backported to stable 3.14 versions. The above
> patches are part of Linus tree, but merged after v3.14 has been
> released. However, they fix a regression introduced by cd14ef54d25b
> (igb: Change to use statically allocated array for MSIx entries), which
> is part of v3.14.
> 
> And I'm actually experiencing a crash igb_reset_q_vector() on a system
> which has MSI support, but not MSI-X support, and basically the code
> path of the driver which fallbacks from MSI-X to MSI is the one
> crashing. With both of these patches applied on top of 3.14, my igb NIC
> works fine.

Any news about these patches?

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
