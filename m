From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 0/2] net: ethernet: ti: cpsw: fix susp/resume
Date: Fri, 10 Feb 2017 12:05:07 -0600
Message-ID: <ffaeb9fe-fd0a-3735-9f72-dded96de6e56@ti.com>
References: <1486598856-3512-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <20170209.172126.155005439329995220.davem@davemloft.net>
 <20170209225423.GA15853@khorivan>
 <20170209.204507.954952367013216032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <mugunthanvnm@ti.com>, <netdev@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <AStarikovskiy@topcon.com>
To: David Miller <davem@davemloft.net>, <ivan.khoronzhuk@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170209.204507.954952367013216032.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 02/09/2017 07:45 PM, David Miller wrote:
> From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> Date: Fri, 10 Feb 2017 00:54:24 +0200
>
>> On Thu, Feb 09, 2017 at 05:21:26PM -0500, David Miller wrote:
>>> From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>>> Date: Thu,  9 Feb 2017 02:07:34 +0200
>>>
>>>> These two patches fix suspend/resume chain.
>>>
>>> Patch 2 doesn't apply cleanly to the 'net' tree, please
>>> respin this series.
>>
>> Strange, I've just checked it on net-next/master, it was applied w/o any
>> warnings.
>
> It makes no sense to test "net-next" when I am telling you that it is
> the "net" tree it doesn't apply to.
>
> This is a bug fix, so it should be targetting the "net" tree.
>

Looks like the first fix is for net, but the second one is for net-next
I do not see
03fd01ad0eead23eb79294b6fb4d71dcac493855
"net: ethernet: ti: cpsw: don't duplicate ndev_running"
in net.

-- 
regards,
-grygorii
