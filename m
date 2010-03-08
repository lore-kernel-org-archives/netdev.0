From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND #2] ipg: Remove device claimed by dl2k from pci
 id table
Date: Mon, 08 Mar 2010 12:57:00 -0800 (PST)
Message-ID: <20100308.125700.04760925.davem@davemloft.net>
References: <4B9563B6.9070803@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, sorbica@icplus.com.tw, netdev@vger.kernel.org
To: jeffm@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51189
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755423Ab0CHU4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:56:41 -0500
In-Reply-To: <4B9563B6.9070803@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Mahoney <jeffm@suse.com>
Date: Mon, 08 Mar 2010 15:53:10 -0500

> ipg: Remove device claimed by dl2k from pci id table
> 
>  This patch removes D-Link DGE-550T PCI ID (1186:4000) from the ipg
>  driver. The ipg driver is for IP2000-based cards and the DGE-550T is
>  a DL2000-based card. The driver loads and works for a few moments, but
>  once a real workload is applied it stops operating. The ipg driver
>  claimed this ID since it was introduced in 2.6.24 and it's forced many
>  users to blacklist it.
> 
>  The correct driver for this hardware is the dl2k driver, which has been
>  claiming this PCI ID since the 2.4 days.
> 
> Signed-off-by: Jeff Mahoney <jeffm@suse.com>

Please stop re-submitting this, it's already in the tree:

commit 25cca5352712561fba97bd37c495593d641c1d39
Author: Jeff Mahoney <jeffm@suse.com>
Date:   Thu Feb 11 10:26:38 2010 +0000

    ipg: Remove device claimed by dl2k from pci id table
    
    This patch removes D-Link DGE-550T PCI ID (1186:4000) from the ipg
    driver. The ipg driver is for IP2000-based cards and the DGE-550T is
    a DL2000-based card. The driver loads and works for a few moments, but
    once a real workload is applied it stops operating. The ipg driver
    claimed this ID since it was introduced in 2.6.24 and it's forced many
    users to blacklist it.
    
    The correct driver for this hardware is the dl2k driver, which has been
    claiming this PCI ID since the 2.4 days.
    
    Signed-off-by: Jeff Mahoney <jeffm@suse.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

