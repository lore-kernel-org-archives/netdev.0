From: Simon Horman <horms@verge.net.au>
Subject: Re: [patch for 2.6.27? 2/2] drivers/net/netxen/netxen_nic_hw.c:
	fix printk warnings
Date: Fri, 1 Aug 2008 16:19:53 +1000
Message-ID: <20080801061952.GI27241@verge.net.au>
References: <200807301950.m6UJoDY4013256@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59272 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbYHAGTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 02:19:55 -0400
Content-Disposition: inline
In-Reply-To: <200807301950.m6UJoDY4013256@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 30, 2008 at 12:50:12PM -0700, akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_nic_pci_mem_read_direct':
> drivers/net/netxen/netxen_nic_hw.c:1414: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'u64'
> drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_nic_pci_mem_write_direct':
> drivers/net/netxen/netxen_nic_hw.c:1487: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'u64'
> 
> You don't know what type was used for u64 hence they cannot be printed without
> casting.

Good grief, that is a sledgehammer to crack an egg.
Pity it is the only tool available :-(

-- 
Horms

