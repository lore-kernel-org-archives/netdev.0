From: Pavel Fedin <p.fedin@samsung.com>
Subject: RE: [PATCH] net: thunder: Fix crash upon shutdown after failed probe
Date: Mon, 16 Nov 2015 16:21:06 +0300
Message-ID: <00c301d12071$c4b8be50$4e2a3af0$@samsung.com>
References: <1447329318-7840-1-git-send-email-p.fedin@samsung.com>
 <20151115.183037.1090427973434503108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgoutham@cavium.com, rric@kernel.org,
	youngmin.lee@cavium.com, kin-yip.liu@cavium.com
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.w1.samsung.com ([210.118.77.14]:15707 "EHLO
	mailout4.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbbKPNWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 08:22:04 -0500
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NXW004TPT4PFP60@mailout4.w1.samsung.com> for
 netdev@vger.kernel.org; Mon, 16 Nov 2015 13:22:01 +0000 (GMT)
In-reply-to: <20151115.183037.1090427973434503108.davem@davemloft.net>
Content-language: ru
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hello!

> > If device probe fails, driver remains bound to the PCI device. However,
> > driver data has been reset to NULL. This causes crash upon dereferencing
> > it in nicvf_remove()
> >
> > Signed-off-by: Pavel Fedin <p.fedin@samsung.com>
> 
> Applied, thanks.

 Thank you very much, however i've just found one more case where i still get this crash. I should have done this from the
beginning, but please revert it in your repo, i'm sending v2, which covers more cases.
 The new case is feeding the device to vfio after the probe failed. In this case nicvf_remove() is called upon unbind.

Kind regards,
Pavel Fedin
Expert Engineer
Samsung Electronics Research center Russia
