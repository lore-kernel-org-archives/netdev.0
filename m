From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/4] [RFC] e1000: make ioport free for supported devices
Date: Wed, 05 Mar 2008 06:32:11 -0500
Message-ID: <47CE84BB.1010408@garzik.org>
References: <20080303223731.16344.94975.stgit@localhost.localdomain> <20080303223737.16344.16498.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48381 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753216AbYCELcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 06:32:13 -0500
In-Reply-To: <20080303223737.16344.16498.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> From: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
> 
> Most e1000 devices do not need ioport access to function properly.
> This is desirable for a few massive homed systems where ioport
> resources become constrained.
> 
> This patch is based on the code from Tomohiro Kusumi, heavily
> modified to fit PCI API changes and e1000 driver changes.
> 
> Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

I don't think you need pci_select_bars()?  It should just be 
pci_enable_device_mem() in both paths AFAICS...

