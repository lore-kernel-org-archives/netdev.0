From: "Haruki Dai-r35557" <Dai.Haruki@freescale.com>
Subject: RE: [PATCH] Gianfar SKB Recycling Support
Date: Wed, 17 May 2006 19:03:33 -0700
Message-ID: <18AEF66AFDF06F4CAAA1D419D000FD33524B9D@az33exm24.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Fleming Andy-afleming" <afleming@freescale.com>,
	"Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:21932 "EHLO
	az33egw01.freescale.net") by vger.kernel.org with ESMTP
	id S1751151AbWERCDi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 22:03:38 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id k4I2NSSH006602
	for <netdev@vger.kernel.org>; Wed, 17 May 2006 19:23:28 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id k4I23b1s007356
	for <netdev@vger.kernel.org>; Wed, 17 May 2006 21:03:37 -0500 (CDT)
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@osdl.org] 
> Sent: Wednesday, May 17, 2006 5:49 PM
> To: Haruki Dai-r35557
> Cc: netdev@vger.kernel.org; Fleming Andy-afleming; Kumar 
> Gala; Haruki Dai-r35557
> Subject: Re: [PATCH] Gianfar SKB Recycling Support
> 
> On Wed, 17 May 2006 15:45:14 -0700
> "Haruki Dai-r35557" <Dai.Haruki@freescale.com> wrote:
> 
> > This patch improves the IP forwarding throughput of
> > the Freescale TSEC/eTSEC Gianfar driver. By recycling
> > the Socket buffer and Data buffer, reduce the unnecessary
> > memory allocation and de-allocation in the forwarding
> > processing chain.
> > 
> > Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> > Signed-off-by: Andy Fleming <afleming@freescale.com>
> > 
> 
> What if I am forwarding from gianfar to e1000?
> 

If the traffic is bidirectional, then the throughput is going up.
If, the e1000 driver also has the buffer recycling routine implemented,
boost up in the both direction.

Regards
Dai
