From: Steve Wise <swise@opengridcomputing.com>
Subject: RE: [openib-general] [PATCH v2 1/7] AMSO1100 Low Level Driver.
Date: Thu, 15 Jun 2006 16:58:29 -0500
Message-ID: <1150408709.6612.16.camel@stevo-desktop>
References: <54AD0F12E08D1541B826BE97C98F99F15767E3@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bob Sharp <bsharp@NetEffect.com>,
	openib-general <openib-general@openib.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:35588 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1031507AbWFOV6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2006 17:58:31 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F15767E3@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Now that I've looked more into this, I'm not sure there's a
> > simple way for the IWCM to copy the pdata on the upcall.
> > Currently, the IWCM's event upcall, cm_event_handler(),
> > simply queues the work for processing on a workqueue thread.
> > So there's no per-event logic at all there.
> > Lemme think on this more.  Stay tuned.
> > 
> > Either way, the amso driver has a memory leak...
> > 
> 
> Having the IWCM copy the pdata during the upcall also leaves
> the greatest flexibility for the driver on how/where the pdata
> is captured. The IWCM has to deal with user-mode, indefinite
> delays waiting for a response and user-mode processes that die
> while holding a connection request. So it makes sense for that
> layer to do the allocating and copying.

I've already coded and test this.  The IWCM will copy the pdata...

Steve.

