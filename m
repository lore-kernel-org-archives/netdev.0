From: "Govindarajan, Sriramakrishnan" <srk@ti.com>
Subject: RE: Adding Support for SG,GSO,GRO
Date: Thu, 9 Dec 2010 20:19:22 +0530
Message-ID: <FCCFB4CDC6E5564B9182F639FC356087035F21DBA0@dbde02.ent.ti.com>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
 <1291891816.4063.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:45783 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210Ab0LIOt1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 09:49:27 -0500
In-Reply-To: <1291891816.4063.5.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,
> > Internally the module supports scatter gather DMA(which is currently not
> > exercised) but there is no HW checksum support.
> >
> > To specifically implement GRO, GSO support would it be sufficient to add
> > SG support to the driver? Are there other means of increasing the
> throughput
> > and decreasing the CPU loading?
> >
> > Any pointers to reference implementation for adding SG/GRO/GSO support
> will be helpful.
> 
> Adding GRO is pretty easy, since you already are NAPI.
> 
> call
> 	napi_gro_receive(&adapter->napi, skb)
> instead of
> 	netif_receive_skb(skb);
> 

[Sriram] I have tried this, but didn't see any improvement in performance.
For GRO and GSO, will adding SG capability alone suffice or the real gains
are realized only if HW checksum is also supported.

Can adding SG support alone yield any improvement?

Regards
Sriram
