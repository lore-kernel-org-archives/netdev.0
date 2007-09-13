From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG] tg3 cannot do PXE (loses MAC address) after soft
 reboot
Date: Thu, 13 Sep 2007 13:47:52 -0700
Message-ID: <1189716472.9540.106.camel@dell>
References: <20070913083918.GA5386@xanadu.blop.info>
 <1551EAE59135BE47B544934E30FC4FC002AABA5B@nt-irva-0751.brcm.ad.broadcom.com>
 <20070913154110.GA25781@xanadu.blop.info>
 <1189706701.9540.84.camel@dell>
 <20070913192812.GA12053@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev" <netdev@vger.kernel.org>
To: "Lucas Nussbaum" <lucas.nussbaum@imag.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3376 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753577AbXIMTuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 15:50:52 -0400
In-Reply-To: <20070913192812.GA12053@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-09-13 at 21:28 +0200, Lucas Nussbaum wrote:

> Erm, Wouldn't it be possible to print a warning when the driver loads,
> saying that the firmware is outdated ?

It's possible, but would require the driver to parse the version string.
The driver currently reports the version string for information and for
the human to parse it.

