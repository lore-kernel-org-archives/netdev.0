From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: fec: ptp: fix convergence issue to support LinuxPTP
 stack
Date: Tue, 14 Oct 2014 20:39:33 +0200
Message-ID: <20141014183933.GA14216@localhost.localdomain>
References: <1413265187-5228-1-git-send-email-b38611@freescale.com>
 <20141014103610.GA4019@localhost.localdomain>
 <20141014.125239.1562178476120218308.davem@davemloft.net>
 <7e6db0b336a340bd80b62475fca284fc@BLUPR03MB486.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "Frank.Li@freescale.com" <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:62314 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbaJNSjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 14:39:39 -0400
Received: by mail-wi0-f173.google.com with SMTP id fb4so10975821wid.6
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 11:39:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <7e6db0b336a340bd80b62475fca284fc@BLUPR03MB486.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank,

On Tue, Oct 14, 2014 at 06:27:28PM +0000, Frank.Li@freescale.com wrote:
> Fugang's patch fix the problem existed in MX6SX platform.

You say that Fugang's patch fixes a quirk in the SX device.

But he said that the user's manual tells us to wait for some status
bits to clear. (See the third line, with the 'while' key word).

> > > On Tue, Oct 14, 2014 at 01:39:47PM +0800, Fugang Duan wrote:
> > >> IEEE 1588 module has one hw issue in capturing the ATVR register.
> > >> According to the user manual it is:
> > >> 		ENET0->ATCR |= ENET_ATCR_CAPTURE_MASK;
> > >> 		while(ENET0->ATCR & ENET_ATCR_CAPTURE_MASK);
> > >> 		ts_counter_ns = ENET0->ATVR;

That applies to all IMX devices, doesn't it?
In any case, Fugang's change log is not clear.

Confused,
Richard
