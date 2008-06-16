From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 rx descriptors
Date: Mon, 16 Jun 2008 22:34:13 +0200
Message-ID: <20080616203413.GB7402@electric-eye.fr.zoreil.com>
References: <20080615211030.M80450@visp.net.lb> <20080615220410.GA10522@electric-eye.fr.zoreil.com> <20080616103524.M79928@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:55873 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753618AbYFPVDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 17:03:40 -0400
Content-Disposition: inline
In-Reply-To: <20080616103524.M79928@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko <denys@visp.net.lb> :
[...]
> After lowering RX_FIFO_THRESH to 5 (i tried 6, also crashed), it crashes after
> few seconds. Maybe it is not real bug, just driver not supposed to handle
> lower values.

No, no, the driver should not notice.

> But maybe it's triggering some bug ?

Does it exhibit the same behavior if you do not use netconsole ?

-- 
Ueimor
