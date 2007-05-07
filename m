From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 10/11][TG3]: Reduce spurious interrupts.
Date: Mon, 07 May 2007 11:41:17 -0700
Message-ID: <1178563277.4859.77.camel@dell>
References: <1551EAE59135BE47B544934E30FC4FC0940105@nt-irva-0751.brcm.ad.broadcom.com>
 <463F5655.7050107@hp.com> <1178562469.4859.70.camel@dell>
 <463F656E.5060802@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, jeff@garzik.org,
	"netdev" <netdev@vger.kernel.org>
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1979 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569AbXEGRxs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 13:53:48 -0400
In-Reply-To: <463F656E.5060802@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-07 at 10:44 -0700, Rick Jones wrote:
> 
> Mostly I was thinking that not all PIO reads are the same "length" and so the 
> effect of the PIO read will vary, perhaps considerably, with the platform, 
> particularly for a very large NUMA platform.
> 

Oh I see.  If the PIO read is "long" on the platform, the performance
impact will be bigger.  But it probably also means that it takes longer
for the write to get to the chip to de-assert the IRQ.  Without the
read, it is therefore more likely to get an extra interrupt in such a
case.


