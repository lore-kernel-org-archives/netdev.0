From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] ixgbe: Fixing EEH handler to handle more than one error
Date: Mon, 16 Nov 2009 11:01:13 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0911161100030.16132@ppwaskie-MOBL2.amr.corp.intel.com>
References: <1257878267-7489-1-git-send-email-leitao@linux.vnet.ibm.com>
 <20091115.221628.243358818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32761 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752731AbZKPTBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 14:01:08 -0500
In-Reply-To: <20091115.221628.243358818.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 Nov 2009, David Miller wrote:

> From: leitao@linux.vnet.ibm.com
> Date: Tue, 10 Nov 2009 13:37:47 -0500
> 
> > After commmit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff EEH breaks
> > after the second error, since it calls pci_restore_state()
> > but it returns 0, since pci->state_saved is false.
> > 
> > So, this patch just call pci_save_state() after pci_restore_state().
> > 
> > Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> 
> Intel folks, are you integrating or looking at this patch?

This patch looks correct and makes sense to me.  I'm going to ACK it now, 
but we'll still pull it in and test it.  If we see any issues, we'll 
report them with possible fixes.  But at this point, I think this patch is 
fine.

Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
