From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Driver for IXP4xx built-in Ethernet ports
Date: Mon, 28 Apr 2008 11:16:46 +0200
Message-ID: <m34p9mfif5.fsf@maximus.localdomain>
References: <m3r6d05ucg.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from OSB1387.piap.pl ([195.187.100.11]:38586 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755234AbYD1JQt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 05:16:49 -0400
In-Reply-To: <m3r6d05ucg.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Sun\, 20 Apr 2008 19\:06\:39 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Adds a driver for built-in IXP4xx Ethernet ports.

Thanks for applying those other two patches, Jeff.

And if you worry about this one and specifically about these two
included fixes to arch/arm/mach-ixp4xx/ixp4xx_npe.c and ixp4xx_qmgr.c,
I believe they don't need to go through Russell's patch system, and
I maintain the files, there is no potential conflict. I guess you can
take this patch safely.

Alternatively I can omit the changes and submit them separately, your
call.

You have already acked a previous version of this driver, I have
changed NAPI interface (as needed by 2.6.24) since then.

TIA.
-- 
Krzysztof Halasa
