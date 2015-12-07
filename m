From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [PATCH net-next] net: hns: optimize XGE capability by reducing
 cpu usage
Date: Mon, 7 Dec 2015 16:37:38 +0800
Message-ID: <56654552.6030105@huawei.com>
References: <1449300749-50275-1-git-send-email-yankejian@huawei.com>
 <20151206.222929.804694720513782203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <lisheng011@huawei.com>, <lipeng321@huawei.com>,
	<salil.mehta@huawei.com>, <huangdaode@hisilicon.com>,
	<xuwei5@hisilicon.com>, <liguozhu@huawei.com>,
	<haifeng.wei@huawei.com>, <yisen.zhuang@huawei.com>,
	<linuxarm@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151206.222929.804694720513782203.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2015/12/7 11:29, David Miller wrote:
> From: yankejian <yankejian@huawei.com>
> Date: Sat, 5 Dec 2015 15:32:29 +0800
>
>> +#if (PAGE_SIZE < 8192)
>> +	if (hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048) {
>> +		truesize = hnae_buf_size(ring);
>> +	} else {
>> +		truesize = ALIGN(size, L1_CACHE_BYTES);
>> +		last_offset = hnae_page_size(ring) - hnae_buf_size(ring);
>> +	}
>> +
>> +#else
>> +		truesize = ALIGN(size, L1_CACHE_BYTES);
>> +		last_offset = hnae_page_size(ring) - hnae_buf_size(ring);
>> +#endif
> This is not indented properly, and it looks terrible.
>
> .
>
Hi David,
Thanks for pointing it out. i will pay attention next time.
