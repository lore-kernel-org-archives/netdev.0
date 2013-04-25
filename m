From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 5/7] qlcnic: Rename the IRQ description.
Date: Thu, 25 Apr 2013 01:05:30 +0100
Message-ID: <1366848330.2600.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
	 <1366843365-2787-6-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<sony.chacko@qlogic.com>, <shahed.shaikh@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:48045 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758600Ab3DYAFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 20:05:35 -0400
In-Reply-To: <1366843365-2787-6-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 18:42 -0400, Jitendra Kalsaria wrote:
> From: Himanshu Madhani <himanshu.madhani@qlogic.com>
> 
> Here's what modified vectors will look like
> in the /proc/interrupts
> 
>         MSIx             	INTx
> -----------------------------------------
> 83xx    qlcnic[MB]
> 	qlcnic-ethX[Rx0]
> 	qlcnic-ethX[Rx1]
> 	..
> 	qlcnic-ethX[RxN]
> 	qlcnic-ethx[Tx0]        qlcnic[MB+Tx0+Rx0]
> 
> 82xx    qlcnic-ethX[Rx0]
> 	qlcnic-ethX[Rx1]
> 	..
> 	qlcnic-ethX[Tx0+RxN]    qlcnic-ethX[Tx0+Rx0]
[...]

Many other multiqueue drivers (including your own qlge) use these
formats for IRQ handler names:

RX queue:   <device>-rx-<index>
TX queue:   <device>-tx-<index>
Queue pair: <device>-<index>

Please use similar formats.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
