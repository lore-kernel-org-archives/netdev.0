From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixgbe: Fixing EEH handler to handle more than one error
Date: Sun, 15 Nov 2009 22:16:28 -0800 (PST)
Message-ID: <20091115.221628.243358818.davem@davemloft.net>
References: <1257878267-7489-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	jeffrey.t.kirsher@intel.com
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58969
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751276AbZKPGQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 01:16:12 -0500
In-Reply-To: <1257878267-7489-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Tue, 10 Nov 2009 13:37:47 -0500

> After commmit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff EEH breaks
> after the second error, since it calls pci_restore_state()
> but it returns 0, since pci->state_saved is false.
> 
> So, this patch just call pci_save_state() after pci_restore_state().
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Intel folks, are you integrating or looking at this patch?

Thanks.
