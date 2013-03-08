From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rrunner.c: fix possible memory leak in rr_init_one()
Date: Fri, 08 Mar 2013 12:32:10 -0500 (EST)
Message-ID: <20130308.123210.2264544388832454980.davem@davemloft.net>
References: <513A1E8A.7040408@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jes@trained-monkey.org
To: daveo@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56967 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755874Ab3CHRcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:32:12 -0500
In-Reply-To: <513A1E8A.7040408@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Oostdyk <daveo@ll.mit.edu>
Date: Fri, 8 Mar 2013 12:23:22 -0500

>    out:
> +	if (rrpriv->evt_ring)
> + pci_free_consistent(pdev, EVT_RING_SIZE, rrpriv->evt_ring,
> +				    rrpriv->evt_ring_dma);

Please resend this without the patch being corrupted by your
email client.

Read Documentation/email-clients.txt, and use it to correct this.

Send a test patch to yourself, and only after you can successfully
apply such a patch sent to your yourself should you resubmit your
patch here.

Thanks.
