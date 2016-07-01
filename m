From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: add reset_resume quirk to prevent resume
 failure
Date: Fri, 01 Jul 2016 15:58:38 -0400 (EDT)
Message-ID: <20160701.155838.304989883410639353.davem@davemloft.net>
References: <1387942633.112861467283319260.JavaMail.weblogic@epmlwas03c>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hemanshu.s@samsung.com,
	vikas.bansal@samsung.com
To: vivek.bhagat@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbcGAT6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 15:58:41 -0400
In-Reply-To: <1387942633.112861467283319260.JavaMail.weblogic@epmlwas03c>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivek Kumar Bhagat <vivek.bhagat@samsung.com>
Date: Thu, 30 Jun 2016 10:41:59 +0000 (GMT)

> 
> Ideally, usbnet_resume is sufficient for device resume operation.
> since usbcore function usb_resume_device() sets udev->reset_resume
> flag as a quirk solution, reset_resume() quirk we can keep in
> class driver also. We checked on dongle DA-Queen UFE20C,
> without reset function resume operation fails. Reason could be
> some power glitch during suspend time due to which device lose
> its internal state and it needs a device phy reset again during
> resume to recover.
> 
> Signed-off-by: Vivek Kumar Bhagat <vivek.bhagat@samsung.com>
> Signed-off-by: Vikas Bansal <vikas.bansal@samsung.com>
> Signed-off-by: Sangmin Bae <sm79.bae@samsung.com>

You've seen this necessary for one device, yet you are doing this
new reset for all usbnet devices.

That doesn't sound correct or safe at all.

I'm not applying this, sorry.
