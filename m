From: David Miller <davem@davemloft.net>
Subject: Re: WARNING: drivers/net/ethernet/dlink/sundance.o(.text+0x2e87):
 Section mismatch in reference from the function sundance_probe1() to the
 variable .devinit.rodata:sundance_pci_tbl
Date: Wed, 05 Dec 2012 12:50:06 -0500 (EST)
Message-ID: <20121205.125006.830180895260845549.davem@davemloft.net>
References: <50be77ca.95imDYp6GlyHjRuw%fengguang.wu@intel.com>
	<CAOJe8K3xBAuhVND-9dJgSxShhpHQ3zko=bE2CNrAKVa-gvDouA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, wfp5p@virginia.edu, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102Ab2LERuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 12:50:10 -0500
In-Reply-To: <CAOJe8K3xBAuhVND-9dJgSxShhpHQ3zko=bE2CNrAKVa-gvDouA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Wed, 5 Dec 2012 11:12:32 +0300

> I"ll fix it.

You can't.

It's only going to get fixed by a change in Greg KH's device tree
which updates the PCI table macros to not use __dev* section tags.

Fengguant, _PLEASE_, as Greg requested, stop reporting these section
mismatch errors, they aren't helpful and are wasting valuable
developer time.
