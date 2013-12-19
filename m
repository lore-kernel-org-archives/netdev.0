From: "Frank.Li@freescale.com" <Frank.Li@freescale.com>
Subject: RE: [PATCH] net: fec: fix potential use after free
Date: Thu, 19 Dec 2013 19:55:22 +0000
Message-ID: <d3799f7147c5439b8f03297e61e05bef@BLUPR03MB486.namprd03.prod.outlook.com>
References: <1387479182.19078.369.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131219193231.GB14612@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0209.outbound.protection.outlook.com ([207.46.163.209]:13832
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756153Ab3LSUL4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:11:56 -0500
In-Reply-To: <20131219193231.GB14612@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, December 19, 2013 1:33 PM
> To: Eric Dumazet
> Cc: David Miller; netdev; Li Frank-B20596
> Subject: Re: [PATCH] net: fec: fix potential use after free
> 
> On Thu, Dec 19, 2013 at 10:53:02AM -0800, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > skb_tx_timestamp(skb) should be called _before_ TX completion has a
> > chance to trigger, otherwise it is too late and we access freed
> > memory.
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Fixes: de5fb0a05348 ("net: fec: put tx to napi poll function to fix
> > dead lock")
> 
> So the hw_lock spin lock was protecting against this issue?
> 
> Nice catch. How ever did you find this?
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>
> 

Acked-by: Frank Li <Frank.Li@freescale.com>
