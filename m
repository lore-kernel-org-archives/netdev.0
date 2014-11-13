From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: r8a779x: Enable automatically fetch receive descriptor
Date: Fri, 14 Nov 2014 00:59:37 +0300
Message-ID: <546529C9.3080907@cogentembedded.com>
References: <1415861819-27812-1-git-send-email-ykaneko0929@gmail.com> <20141113.150311.1961794581032201784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au, magnus.damm@gmail.com,
	linux-sh@vger.kernel.org, grant.likely@linaro.org
To: David Miller <davem@davemloft.net>, ykaneko0929@gmail.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20141113.150311.1961794581032201784.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/13/2014 11:03 PM, David Miller wrote:

>> From: Kouei Abe <kouei.abe.cp@renesas.com>

>> HDMAC automatically fetches the receive descriptor and receives frames.
>> Continuous reception of multiple frames is possible.

>> Signed-off-by: Kouei Abe <kouei.abe.cp@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>> ---
>>
>> This patch is based on net-next tree.
>
> This doesn't even compile, or, it depends upon another patch which you have
> not mentioned.

    This patch is just very outdated -- this issue has been fixed for all SoCs 
before.

> Because sh_eth_cpu_data does not have an rmcr_value field.

     Right, it was removed by the above mentioned patch (based on your 
feedback BTW ;-).

WBR, Sergei

