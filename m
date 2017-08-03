From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 net-next 02/21] net-next/hinic: Initialize hw device
 components
Date: Thu, 03 Aug 2017 15:34:28 -0700 (PDT)
Message-ID: <20170803.153428.1458452200774139189.davem@davemloft.net>
References: <cover.1501752425.git.aviad.krawczyk@huawei.com>
        <f15df6eed91d1a2b05864be90928b8e778d270e2.1501752425.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        bc.y@huawei.com, victor.gissin@huawei.com, zhaochen6@huawei.com,
        tony.qu@huawei.com
To: aviad.krawczyk@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50394 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752100AbdHCWe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 18:34:29 -0400
In-Reply-To: <f15df6eed91d1a2b05864be90928b8e778d270e2.1501752425.git.aviad.krawczyk@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Date: Thu, 3 Aug 2017 17:54:08 +0800

> +static int get_capability(struct hinic_hwdev *hwdev,
> +			  struct hinic_dev_cap *dev_cap)
> +{
> +	struct hinic_hwif *hwif = hwdev->hwif;
> +	struct hinic_cap *nic_cap = &hwdev->nic_cap;
> +	int num_aeqs, num_ceqs, num_irqs, num_qps;

Please order local variable declarations from longest to shortest
line (aka: reverse christmas tree order).

Move the initialization down into the code if that is necessary
to achiever this.

> +static int get_dev_cap(struct hinic_hwdev *hwdev)
> +{
> +	struct hinic_pfhwdev *pfhwdev;
> +	struct hinic_hwif *hwif = hwdev->hwif;
> +	struct pci_dev *pdev = hwif->pdev;
> +	int err;

Likewise.
