From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [IOC3] Switch to pci refcounting safe APIs
Date: Tue, 10 Jul 2007 12:29:39 -0400
Message-ID: <4693B3F3.4040102@garzik.org>
References: <20070710160516.GA25176@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60064 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755016AbXGJQ3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:29:43 -0400
In-Reply-To: <20070710160516.GA25176@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> From:	Alan Cox <alan@lxorguk.ukuu.org.uk>
> 
> Convert the IOC3 driver to use ref counting pci interfaces so that we can
> obsolete the (usually unsafe) pci_find_{slot/device} interfaces and avoid
> future authors writing hotplug-unsafe device drivers.
> 
> Signed-off-by: Alan Cox <alan@redhat.com>
> 
> Build fixes:
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

applied


