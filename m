From: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Subject: RE: [PATCH] vxge: fix memory leak in vxge_alloc_msix() error path
 {nodisc}
Date: Fri, 25 Jun 2010 00:21:48 -0700
Message-ID: <FCA91A92EE52B041906A0358FC28FCC38EF1837D08@FRE1EXCH02.hq.exar.com>
References: <20100624161344.0847a7ca@leela>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:33347 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751679Ab0FYHVu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 03:21:50 -0400
In-Reply-To: <20100624161344.0847a7ca@leela>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> When pci_enable_msix() returned ret<0, entries and vxge_entries were
> leaked.
> While at it, use the centralized exit idiom in the function.
> 
> Not tested. It compiles OK.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Reviewed and tested the patch. Thanks!

Acked-by: Ram Vepa <ram.vepa@exar.com>
