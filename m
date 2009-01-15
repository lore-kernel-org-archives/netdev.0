From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC v5] net: add PCINet driver
Date: Thu, 15 Jan 2009 23:53:24 +0100
Message-ID: <200901152353.25052.arnd@arndb.de>
References: <20090107195052.GA24981@ovro.caltech.edu> <200901152222.55006.arnd@arndb.de> <20090115214056.GC9091@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ira Snyder <iws@ovro.caltech.edu>,
	Jan-Bernd Themann <themann@de.ibm.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:50962 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936629AbZAOWyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 17:54:05 -0500
In-Reply-To: <20090115214056.GC9091@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 January 2009, Ira Snyder wrote:
> I do have mailboxes (two inbound, two outbound) which can generate
> interrupts, as well as doorbell registers (one inbound, one outbound).
> The doorbell register's bits are "write 1 to clear", and can only be
> cleared by the opposite side.
> 

Ok, in this case, you should be able to use one of these to implement
the DMA complete interrupt, but adding an extra DMA transfer to the
mailbox after each transfer that you want to get notified for.

	Arnd <><
