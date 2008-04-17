From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] RESEND 8390: Split 8390 support into a pausing and a
 non pausing driver core
Date: Thu, 17 Apr 2008 06:32:59 +0100
Message-ID: <20080417063259.62ef8a52@the-village.bc.nu>
References: <20080119155817.326ee5e0@lxorguk.ukuu.org.uk>
	<48069DE1.7080301@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, NetDev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [85.114.38.90] ([85.114.38.90]:55383 "EHLO the-village.bc.nu"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755822AbYDQOnh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 10:43:37 -0400
In-Reply-To: <48069DE1.7080301@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Now that this has seen a bit of testing, and accumulated some fix 
> patches in -mm, can I get a roll-up of all those into a single patch?
> 
> Looks OK to me.  My one minor comment is that I would think the 
> init_module() would be superfluous?


The new module is generated directly from the old one so possibly neither
need it.

Alan
