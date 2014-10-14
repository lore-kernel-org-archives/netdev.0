From: "Frank.Li@freescale.com" <Frank.Li@freescale.com>
Subject: RE: [PATCH] net: fec: ptp: fix convergence issue to support LinuxPTP
 stack
Date: Tue, 14 Oct 2014 18:43:51 +0000
Message-ID: <6b1256b73b7a4f978573a77ec3e36831@BLUPR03MB486.namprd03.prod.outlook.com>
References: <1413265187-5228-1-git-send-email-b38611@freescale.com>
 <20141014103610.GA4019@localhost.localdomain>
 <20141014.125239.1562178476120218308.davem@davemloft.net>
 <7e6db0b336a340bd80b62475fca284fc@BLUPR03MB486.namprd03.prod.outlook.com>
 <20141014183933.GA14216@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0107.outbound.protection.outlook.com ([157.56.111.107]:48042
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754705AbaJNSnx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 14:43:53 -0400
In-Reply-To: <20141014183933.GA14216@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Tuesday, October 14, 2014 1:40 PM
> To: Li Frank-B20596
> Cc: David Miller; Duan Fugang-B38611; netdev@vger.kernel.org;
> bhutchings@solarflare.com
> Subject: Re: [PATCH] net: fec: ptp: fix convergence issue to support LinuxPTP
> stack
> 
> Frank,
> 
> On Tue, Oct 14, 2014 at 06:27:28PM +0000, Frank.Li@freescale.com wrote:
> > Fugang's patch fix the problem existed in MX6SX platform.
> 
> You say that Fugang's patch fixes a quirk in the SX device.
> 
> But he said that the user's manual tells us to wait for some status bits to
> clear. (See the third line, with the 'while' key word).
> 
> > > > On Tue, Oct 14, 2014 at 01:39:47PM +0800, Fugang Duan wrote:
> > > >> IEEE 1588 module has one hw issue in capturing the ATVR register.
> > > >> According to the user manual it is:
> > > >> 		ENET0->ATCR |= ENET_ATCR_CAPTURE_MASK;
> > > >> 		while(ENET0->ATCR & ENET_ATCR_CAPTURE_MASK);
> > > >> 		ts_counter_ns = ENET0->ATVR;
> 
> That applies to all IMX devices, doesn't it?
> In any case, Fugang's change log is not clear.

Only MX6 SX. Only MX6 SX added FEC_QUIRK_BUG_CAPTURE.

.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
 				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
 				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_HAS_AVB |
-				FEC_QUIRK_ERR007885,
+				FEC_QUIRK_ERR007885 | FEC_QUIRK_BUG_CAPTURE,

> 
> Confused,
> Richard
