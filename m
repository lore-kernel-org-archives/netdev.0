From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] vxge: fix crash of VF when unloading PF
Date: Fri, 10 Dec 2010 16:08:58 -0800 (PST)
Message-ID: <20101210.160858.212411633.davem@davemloft.net>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
	<1292025782-16372-2-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sivakumar.subramani@exar.com,
	sreenivasa.honnur@exar.com, ram.vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53864
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757257Ab0LKAIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:08:31 -0500
In-Reply-To: <1292025782-16372-2-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Fri, 10 Dec 2010 18:02:57 -0600

> Calling pci_disable_sriov when unloading a SR-IOV physical function
> driver from a host when a guest is using a virtual function from that
> device can cause a host crash or VM crash.  The crash is caused by the
> virtual config space no longer being present when PF is removed (due to
> the pci_disable_sriov).  This can be avoided by not calling
> pci_disable_sriov to disable the PCI space when shutting down the PF.
> Each function in the X3100 operates independently and in this case will
> operate properly in the absence of the PF.
> 
> Also, added improved logic in the detection of SR-IOV initialization.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>
> Signed-off-by: Ram Vepa <ram.vepa@exar.com>

Applied.
