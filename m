From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [PATCH net-next 9/9] net: hns: get reset registers from DT
Date: Thu, 30 Jun 2016 09:10:52 +0800
Message-ID: <5774719C.4090409@huawei.com>
References: <1467021255-95900-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1467021255-95900-10-git-send-email-Yisen.Zhuang@huawei.com>
 <20160629.051142.259737654994822294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <salil.mehta@huawei.com>, <liguozhu@huawei.com>,
	<huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>, <Yisen.Zhuang@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160629.051142.259737654994822294.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/6/29 17:11, David Miller wrote:
> From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
> Date: Mon, 27 Jun 2016 17:54:15 +0800
>
>> @@ -361,9 +371,10 @@ static int hns_mdio_reset(struct mii_bus *bus)
>>  			return -ENODEV;
>>  		}
>>  
>> +	sc_reg = &mdio_dev->sc_reg;
>>  		/* 1. reset req, and read reset st check */
>> -		ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_RESET_REQ, 0x1,
>> -					    MDIO_SC_RESET_ST, 0x1,
>> +	ret = mdio_sc_cfg_reg_write(mdio_dev, sc_reg->mdio_reset_req, 0x1,
>> +				    sc_reg->mdio_reset_st, 0x1,
>>  					    MDIO_CHECK_SET_ST);
>>  		if (ret) {
>>  			dev_err(&bus->dev, "MDIO reset fail\n");
> What in the world are you doing to the indentation here?
>
> Please read your patches before actually sending them, such things
> will be quite obvious by simple visual inspection.
>
> .
>
Hi David,
i am sorry for my carelessness. i will pay more attention next time.
Thanks for pointing it our

-- 
MBR,
Yankejian (Hackim Yim)
