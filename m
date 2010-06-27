From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxge: fix memory leak in vxge_alloc_msix() error path
 {nodisc}
Date: Sat, 26 Jun 2010 22:12:39 -0700 (PDT)
Message-ID: <20100626.221239.35808969.davem@davemloft.net>
References: <20100624161344.0847a7ca@leela>
	<FCA91A92EE52B041906A0358FC28FCC38EF1837D08@FRE1EXCH02.hq.exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org
To: Ramkrishna.Vepa@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60429
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751084Ab0F0FMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jun 2010 01:12:32 -0400
In-Reply-To: <FCA91A92EE52B041906A0358FC28FCC38EF1837D08@FRE1EXCH02.hq.exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Date: Fri, 25 Jun 2010 00:21:48 -0700

>> When pci_enable_msix() returned ret<0, entries and vxge_entries were
>> leaked.
>> While at it, use the centralized exit idiom in the function.
>> 
>> Not tested. It compiles OK.
>> 
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> 
> Reviewed and tested the patch. Thanks!
> 
> Acked-by: Ram Vepa <ram.vepa@exar.com>

Applied.
