From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] enic: Check for DMA mapping error
Date: Wed, 31 Dec 2014 13:09:12 -0500 (EST)
Message-ID: <20141231.130912.1847974396184956491.davem@davemloft.net>
References: <1419416978-1008-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sassmann@redhat.com, ssujith@cisco.com,
	benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429AbaLaSJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 13:09:15 -0500
In-Reply-To: <1419416978-1008-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed, 24 Dec 2014 15:59:35 +0530

> After dma mapping the buffers, enic does not call dma_mapping_error() to check
> if mapping is successful.
> 
> This series fixes the issue by checking return value of pci_dma_mapping_error()
> after pci_map_single().
> 
> This is reported by redhat here
> https://bugzilla.redhat.com/show_bug.cgi?id=1145016

Series applied, thank you.
