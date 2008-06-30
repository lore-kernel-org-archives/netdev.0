From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [Linux-ATM-General] [PATCH] firmware: convert Ambassador ATM
	driver to request_firmware()
Date: Mon, 30 Jun 2008 15:54:38 +0100
Message-ID: <1214837678.10393.345.camel@pmac.infradead.org>
References: <200806301359.m5UDxcjJ023252@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60397 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758666AbYF3Oym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 10:54:42 -0400
In-Reply-To: <200806301359.m5UDxcjJ023252@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-30 at 09:59 -0400, Chas Williams (CONTRACTOR) wrote:
> In message <1214832072.10393.342.camel@pmac.infradead.org>,David Woodhouse writ
> es:
> >On Mon, 2008-06-30 at 09:15 -0400, Chas Williams (CONTRACTOR) wrote:
> >> In message <1214831362.10393.340.camel@pmac.infradead.org>,David Woodhouse w
> >rit
> >> es:
> >> >And wasn't it sba200e_ecd.bin ? 
> >> 
> >> oops.  sparc is big endian.  adding the const we have...
> >
> >You probably still want the ifdefs for MODULE_FIRMWARE().
> 
> i removed the #ifdef's from around MODULE_LICENSE().  there shouldnt
> be any need for #ifdef's around MODULE_FIRMWARE() either.

Unless you put #ifdef CONFIG_SBUS around the
MODULE_FIRMWARE("sba200e_ecd.bin") you will be requesting that firmware
even on non-sbus machines. Likewise little-endian vs. big-endian on PCI.

-- 
dwmw2

