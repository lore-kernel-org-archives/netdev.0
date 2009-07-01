From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 5/5] igb: return PCI_ERS_RESULT_DISCONNECT on
 permanent error
Date: Tue, 30 Jun 2009 19:54:10 -0700 (PDT)
Message-ID: <20090630.195410.80699368.davem@davemloft.net>
References: <20090630224515.17771.76848.stgit@localhost.localdomain>
	<20090630224633.17771.74883.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50741
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755559AbZGACyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 22:54:04 -0400
In-Reply-To: <20090630224633.17771.74883.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Jun 2009 15:46:34 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> PCI drivers that implement the io_error_detected callback should return
> PCI_ERS_RESULT_DISCONNECT if the state passed in is
> pci_channel_io_perm_failure.  This patch fixes the issue for igb.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
