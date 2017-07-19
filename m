From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 12/21] net-next/hinic: Add qp resources
Date: Wed, 19 Jul 2017 16:13:16 -0700 (PDT)
Message-ID: <20170719.161316.2138496537830668352.davem@davemloft.net>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
        <493b105a36b5ddcf3570ed165aedfb4d6517ee6e.1500454998.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        bc.y@huawei.com, victor.gissin@huawei.com, zhaochen6@huawei.com,
        tony.qu@huawei.com
To: aviad.krawczyk@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <493b105a36b5ddcf3570ed165aedfb4d6517ee6e.1500454998.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Date: Wed, 19 Jul 2017 17:19:10 +0800

> diff --git a/drivers/net/ethernet/huawei/hinic/Makefile b/drivers/net/ethernet/huawei/hinic/Makefile
> index 519382b..24728f0 100644
> --- a/drivers/net/ethernet/huawei/hinic/Makefile
> +++ b/drivers/net/ethernet/huawei/hinic/Makefile
> @@ -1,5 +1,5 @@
>  obj-$(CONFIG_HINIC) += hinic.o
>  
>  hinic-y := hinic_main.o hinic_tx.o hinic_rx.o hinic_port.o hinic_hw_dev.o \
> -	   hinic_hw_io.o hinic_hw_wq.o hinic_hw_mgmt.o hinic_hw_api_cmd.o \
> -	   hinic_hw_eqs.o hinic_hw_if.o
> \ No newline at end of file
> +	   hinic_hw_io.o hinic_hw_qp.o hinic_hw_wq.o hinic_hw_mgmt.o \
> +	   hinic_hw_api_cmd.o hinic_hw_eqs.o hinic_hw_if.o
> \ No newline at end of file

Please add the missing newline to the end of this Makefile so that these patches
don't keep emitting this message.
