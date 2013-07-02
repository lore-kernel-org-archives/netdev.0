From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH] wireless: Convert mwifiex/pcie to dev_pm_ops from
 legacy pm ops
Date: Tue, 2 Jul 2013 12:07:26 -0700
Message-ID: <477F20668A386D41ADCC57781B1F70430EA2E0635A@SC-VEXCH1.marvell.com>
References: <1372778675-2909-1-git-send-email-shuah.kh@samsung.com>
 <51D32116.4010109@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linville@tuxdriver.com" <linville@tuxdriver.com>,
	"rjw@sisk.pl" <rjw@sisk.pl>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shuahkhan@gmail.com" <shuahkhan@gmail.com>
To: Hauke Mehrtens <hauke@hauke-m.de>,
	Shuah Khan <shuah.kh@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:54922 "EHLO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752758Ab3GBTK7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 15:10:59 -0400
In-Reply-To: <51D32116.4010109@hauke-m.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hauke,

Thanks for your comments.

> > @@ -213,7 +227,7 @@ static void mwifiex_pcie_remove(struct pci_dev *pdev)
> >  	if (user_rmmod) {
> >  #ifdef CONFIG_PM
> >  		if (adapter->is_suspended)
> > -			mwifiex_pcie_resume(pdev);
> > +			__mwifiex_pcie_resume(pdev);
> 
> You could use mwifiex_pcie_resume(&pdev->dev) here and then the extra
> function __mwifiex_pcie_resume() is not needed any more.

That makes more sense.

Thanks,
Bing
