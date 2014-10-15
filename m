From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: ptp: fix convergence issue to support LinuxPTP
 stack
Date: Wed, 15 Oct 2014 01:37:14 +0000
Message-ID: <76570f05e2c44b5b92376bb4ce7b7393@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1413265187-5228-1-git-send-email-b38611@freescale.com>
 <20141014103610.GA4019@localhost.localdomain>
 <20141014.125239.1562178476120218308.davem@davemloft.net>
 <7e6db0b336a340bd80b62475fca284fc@BLUPR03MB486.namprd03.prod.outlook.com>
 <20141014183933.GA14216@localhost.localdomain>
 <6b1256b73b7a4f978573a77ec3e36831@BLUPR03MB486.namprd03.prod.outlook.com>
 <20141014184952.GC14216@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0148.outbound.protection.outlook.com ([65.55.169.148]:39193
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755517AbaJOBhR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 21:37:17 -0400
In-Reply-To: <20141014184952.GC14216@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com> Sent: Wednesday, October 15, 2014 2:50 AM
>To: Li Frank-B20596
>Cc: David Miller; Duan Fugang-B38611; netdev@vger.kernel.org;
>bhutchings@solarflare.com
>Subject: Re: [PATCH] net: fec: ptp: fix convergence issue to support
>LinuxPTP stack
>
>On Tue, Oct 14, 2014 at 06:43:51PM +0000, Frank.Li@freescale.com wrote:
>> Only MX6 SX. Only MX6 SX added FEC_QUIRK_BUG_CAPTURE.
>
>But what about this comment:
>
>+/* ENET Block Guide/ Chapter for the iMX6SLX (PELE) address one issue:
>+ * Incorrect behavior for ENET_ATCR[Capture and Restart Bits]. These
>+bits will
>+ * always read a value zero. When these bits are set to 1'b1, these
>+should hold
>+ * value 1'b1 until the counter value is capture in the register clock
>domain.
>+ */
>
>It sounds like the bits are "sticky" until the counter value has been
>latched. Therefore you need to check the bits before reading the counter,
>but the code does not do this for the case of !SX.
>
>Thanks,
>Richard

Hi, Richard,

These "__should__" hold 1'b1 until the counter value is capture in the register clock domain.
But "Incorrect behavior for ENET_ATCR[Capture and Restart Bits]. These bits will always read a value zero"


Thanks,
Andy
