From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: fix pci bar mapping
Date: Sun, 11 Oct 2009 23:06:56 -0700 (PDT)
Message-ID: <20091011.230656.245420067.davem@davemloft.net>
References: <1255315402-1578-1-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36827
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752643AbZJLGHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 02:07:00 -0400
In-Reply-To: <1255315402-1578-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sun, 11 Oct 2009 19:43:22 -0700

> Use phys_addr_t data type for pci resource address
> instead of unsigned long. This fixes mapping of
> pci resources where resource addresses can be larger
> than word size (e.g. PAE).
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

The correct type to use is 'resource_size_t' not 'phys_addr_t'.

Look at the "struct resource" member types in linux/ioport.h, that's
what these pci_resource_start() et al. routines return.

Please fix this up and resubmit.
