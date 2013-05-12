From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] 3c59x: fix PCI resource management
Date: Sat, 11 May 2013 17:40:27 -0700 (PDT)
Message-ID: <20130511.174027.2189352473297054848.davem@davemloft.net>
References: <201305100114.08149.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432Ab3ELAk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 20:40:28 -0400
In-Reply-To: <201305100114.08149.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 10 May 2013 01:14:07 +0400

> From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
> The driver wrongly claimed I/O ports at an address returned by pci_iomap() --
> even if it was passed an MMIO address.  Fix this by claiming/releasing all PCI
> resources in the PCI driver's probe()/remove() methods instead and get rid of
> 'must_free_region' flag weirdness (why would Cardbus claim anything for us?).
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

Applied, thanks.
