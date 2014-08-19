From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v3 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Tue, 19 Aug 2014 01:50:53 +0000
Message-ID: <430c40fbef314217a8c2609b9aebbd90@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1408081975-15087-1-git-send-email-b38611@freescale.com>
 <1408081975-15087-2-git-send-email-b38611@freescale.com>
 <20140815180854.GA6897@localhost.localdomain>
 <b50df5011728419887508cbf3af0a5a7@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140818194151.GA4048@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0185.outbound.protection.outlook.com ([207.46.163.185]:37127
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752336AbaHSBu5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 21:50:57 -0400
In-Reply-To: <20140818194151.GA4048@netboy>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com> Sent: Tuesday, August 19, 2014 3:42 AM
>To: Duan Fugang-B38611
>Cc: davem@davemloft.net; netdev@vger.kernel.org; shawn.guo@linaro.org
>Subject: Re: [PATCH v3 1/1] net: fec: ptp: avoid register access when ipg
>clock is disabled
>
>On Mon, Aug 18, 2014 at 06:07:00AM +0000, fugang.duan@freescale.com wrote:
>> 1. Set the flag to false firstly.
>
>Yes.
>
>> 2. Don't need to add mutex to protect the flag.(My previous mail ask
>> one mutex to protect the flag)
>
>You *do* need a mutex to protect the state of the physical clock. One
>process might turn it off while another process is still reading it.
>
>>    Just pull the flag into the protected field by spin_lock_irqsave()
>like :
>> fec_time_keep()
>
>No, the spin only protects the register access.
>
>Thanks,
>Richard

Ok, I will send the next version with mutex protect the physical clock state.

Thanks,
Andy
