From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [PATCH] firmware: convert Ambassador ATM driver to request_firmware()
Date: Mon, 30 Jun 2008 12:10:47 -0400
Message-ID: <200806301610.m5UGAlqr025302@cmf.nrl.navy.mil>
References: <1214837678.10393.345.camel@pmac.infradead.org>
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:43994 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbYF3QK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 12:10:56 -0400
In-reply-to: <1214837678.10393.345.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1214837678.10393.345.camel@pmac.infradead.org>,David Woodhouse writ
es:
>> i removed the #ifdef's from around MODULE_LICENSE().  there shouldnt
>> be any need for #ifdef's around MODULE_FIRMWARE() either.
>
>Unless you put #ifdef CONFIG_SBUS around the
>MODULE_FIRMWARE("sba200e_ecd.bin") you will be requesting that firmware
>even on non-sbus machines. Likewise little-endian vs. big-endian on PCI.

does it?  i was under the impression that MODULE_FIRMWARE() just
provides a hint that modinfo can read.  request_firmware() still
the requestor for the firmware image.
