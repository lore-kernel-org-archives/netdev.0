From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] 3c59x: fix PCI resource management
Date: Sun, 12 May 2013 16:35:06 -0700 (PDT)
Message-ID: <20130512.163506.42473258916736778.davem@davemloft.net>
References: <201305100114.08149.sergei.shtylyov@cogentembedded.com>
	<20130511.174027.2189352473297054848.davem@davemloft.net>
	<518FB2AB.5050706@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578Ab3ELXfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 May 2013 19:35:09 -0400
In-Reply-To: <518FB2AB.5050706@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 12 May 2013 19:18:03 +0400

> Hello.
> 
> On 12-05-2013 4:40, David Miller wrote:
> 
>>> From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
>>> The driver wrongly claimed I/O ports at an address returned by
>>> pci_iomap() --
>>> even if it was passed an MMIO address.  Fix this by claiming/releasing
>>> all PCI
>>> resources in the PCI driver's probe()/remove() methods instead and get
>>> rid of
>>> 'must_free_region' flag weirdness (why would Cardbus claim anything
>>> for us?).
> 
>>> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
>> Applied, thanks.
> 
>    Thank you. Will you also queue this for -stable?

Queued up, thanks.
