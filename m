From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] skge: use unique IRQ name
Date: Thu, 01 Oct 2009 13:31:55 -0700 (PDT)
Message-ID: <20091001.133155.53607208.davem@davemloft.net>
References: <20091001095032.17271dcc@s6510>
	<20091001200208.2907b8ff@leela>
	<20091001111323.260d49bf@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58596
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754424AbZJAUbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 16:31:35 -0400
In-Reply-To: <20091001111323.260d49bf@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 1 Oct 2009 11:13:23 -0700

> $ grep skge /proc/interrupts
>  17:        169   IO-APIC-fasteoi   skge@0000:00:0a.0, eth0

Please fix this example output to match the code :-)

> +	sprintf(hw->irq_name, DRV_NAME "@pci:%s", pci_name(pdev));

Thanks!
