From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Fri, 15 Aug 2014 03:23:42 +0000
Message-ID: <b0886e9bf4d54c008f78998ae930d712@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1407905705-27984-1-git-send-email-b38611@freescale.com>
 <1407905705-27984-2-git-send-email-b38611@freescale.com>
 <20140813211941.GB4840@netboy>
 <4dcf48cd1c11473c82fcec0c8963ece2@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814081036.GB7555@netboy>
 <e84f5b51501e4add8cf08819c64ef554@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814084251.GC7555@netboy>
 <4977c4d325c949019549211d74c6982d@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814091259.GA11727@netboy>
 <4f93901dbe7a4746aacc795ae825ee60@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140814143351.GA29615@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0140.outbound.protection.outlook.com ([207.46.163.140]:1338
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753405AbaHODXr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 23:23:47 -0400
In-Reply-To: <20140814143351.GA29615@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com> Data: Thursday, August 14, 2014 10:34 PM
>To: Duan Fugang-B38611
>Cc: shawn.guo@linaro.org; davem@davemloft.net; netdev@vger.kernel.org
>Subject: Re: [PATCH v2 1/1] net: fec: ptp: avoid register access when ipg
>clock is disabled
>
>On Thu, Aug 14, 2014 at 09:26:45AM +0000, fugang.duan@freescale.com wrote:
>> When ethx disable, all clocks are disabled. For gettime(), your mean
>> that we check clock is on or not, If clock is disabled, return an error
>in .fec_ptp_gettime() ?
>
>Yes.
>
I will change it. Thanks! I will submit the next version.

Thanks for your review.
