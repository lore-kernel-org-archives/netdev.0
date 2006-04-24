From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Van Jacobson's net channels and real-time
Date: Mon, 24 Apr 2006 16:17:07 -0700
Message-ID: <1145920628.7998.8.camel@rh4>
References: <Pine.LNX.4.44L0.0604201819040.19330-100000@lifa01.phys.au.dk>
 <200604221529.59899.ioe-lkml@rameria.de>
 <20060422134956.GC6629@wohnheim.fh-wedel.de>
 <200604230205.33668.ioe-lkml@rameria.de> <444CFFE5.1020509@intel.com>
 <Pine.LNX.4.61.0604241254180.24099@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Auke Kok" <auke-jan.h.kok@intel.com>,
	"Ingo Oeser" <ioe-lkml@rameria.de>,
	"=?ISO-8859-1?Q?J=F6rn?= Engel" <joern@wohnheim.fh-wedel.de>,
	"Ingo Oeser" <netdev@axxeo.de>,
	"David S. Miller" <davem@davemloft.net>, simlo@phys.au.dk,
	linux-kernel@vger.kernel.org, mingo@elte.hu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:54281 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751284AbWDYA53
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 20:57:29 -0400
To: "linux-os (Dick Johnson)" <linux-os@analogic.com>
In-Reply-To: <Pine.LNX.4.61.0604241254180.24099@chaos.analogic.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-24 at 12:59 -0400, linux-os (Dick Johnson) wrote:

> Message signaled interrupts are just a kudge to save a trace on a
> PC board (read make junk cheaper still). They are not faster and
> may even be slower. They will not be the salvation of any interrupt
> latency problems.

MSI has 2 very nice properties: MSI is never shared and MSI guarantees
that all DMA activities before the MSI have completed. When you take
advantage of these guarantees in your MSI handler, there can be
noticeable improvements compared to using INTA.

