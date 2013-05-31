From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH 6/7] qlcnic: remove redundant D0 power state set
Date: Fri, 31 May 2013 13:48:27 +0000
Message-ID: <C562D0E12CBDE44E8A0CCAB7706009673539F21B@AVMB1.qlogic.org>
References: <1369909569-33096-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	Hanjun Guo <guohanjun@huawei.com>, Jiang Liu <liuj97@gmail.com>
To: Yijing Wang <wangyijing@huawei.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369909569-33096-1-git-send-email-wangyijing@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Yijing Wang [mailto:wangyijing@huawei.com]
>Sent: Thursday, May 30, 2013 3:56 PM
>To: Rajesh Borundia; Shahed Shaikh; Jitendra Kalsaria; Sony Chacko
>Cc: linux-kernel; Dept-Eng Linux Driver; netdev; Hanjun Guo; Jiang Liu;
>Yijing Wang
>Subject: [PATCH 6/7] qlcnic: remove redundant D0 power state set
>
>Pci_enable_device() will set device power state to D0,
>so it's no need to do it again in qlcnic_attach_func().
>
>Signed-off-by: Yijing Wang <wangyijing@huawei.com>
>---
> drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    1 -
> 1 files changed, 0 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>index aeb26a8..3585c2c 100644
>--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
>@@ -3219,7 +3219,6 @@ static int qlcnic_attach_func(struct pci_dev
>*pdev)
> 	if (err)
> 		return err;
>
>-	pci_set_power_state(pdev, PCI_D0);
> 	pci_set_master(pdev);
> 	pci_restore_state(pdev);
>
>--
>1.7.1
>
>

Acked-by: Rajesh Borundia <rajesh.borundia@qlogic.com>

Thanks!
