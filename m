From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [PATCH] firmware: convert Ambassador ATM driver to request_firmware()
Date: Mon, 30 Jun 2008 08:50:41 -0400
Message-ID: <200806301250.m5UCofNg022031@cmf.nrl.navy.mil>
References: <1214818473.10393.337.camel@pmac.infradead.org>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:58165 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558AbYF3Mu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 08:50:56 -0400
Reply-To: chas3@users.sourceforge.net
Reply-To: chas3@users.sourceforge.net
In-reply-to: <1214818473.10393.337.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1214818473.10393.337.camel@pmac.infradead.org>,David Woodhouse writ
es:
>Sorry for dropping this; I'll let it go through the net tree now it's
>there.

ok

>A couple of comments though... it looks like you forgot to add
>MODULE_FIRMWARE(). And shouldn't 'fw_data' in

yes.  i will get davem a patch for that asap.

>fore200e_load_and_start_firmware() be a (__le32 *) not a (u32 *)?

yes, it certainly could be.
