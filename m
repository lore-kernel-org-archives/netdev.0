From: huangdaode <huangdaode@hisilicon.com>
Subject: Re: [PATCH net-next] net: hns: bug fix about hisilicon TSO BD mode
Date: Tue, 19 Jan 2016 09:51:30 +0800
Message-ID: <569D96A2.2080504@hisilicon.com>
References: <1453109056-161865-1-git-send-email-huangdaode@hisilicon.com>
 <20160118.115524.1656097226798937868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<liguozhu@hisilicon.com>, <salil.mehta@huawei.com>,
	<geliangtang@163.com>, <lipeng321@huawei.com>,
	<andriy.shevchenko@linux.intel.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <Kenneth-Lee-2012@foxmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160118.115524.1656097226798937868.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/1/19 0:55, David Miller wrote:
> From: Daode Huang <huangdaode@hisilicon.com>
> Date: Mon, 18 Jan 2016 17:24:16 +0800
>
>> The current upstreaming code fails to set the tso_mode register
>> when initilizes, when processes large size packets, the default 4 bd is
>> not enough, so this patch initilizes it and set the default value to 8 bds
>>
>> Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> Your insistance of continually using "net-next" in your subject lines
> shows you have no idea what GIT trees are active and in what trees
> development and bug fixing is actually occurring in.
>
> The 'net' tree is the only tree active now and your driver has been in
> there for over a week.
>
> And this is the place where all appropriate bug fixes go.
>
> Therefore if your code is present in the 'net' tree and you are fixing
> things in that codebase, then that is the tree you target.
>
> I've been silently applying your patches there instead of net-next,
> but I'm not going to do it any more and I will just reject patches not
> submitted properly from this point forward.
>
> Thanks.
>
> .

Hi David,
Thanks for your comments, will pay more attention to it.

Best Regards
Daode.
