From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V6 21/21] net-next/hinic: Add netpoll
Date: Thu, 17 Aug 2017 15:57:15 +0300
Message-ID: <183ebd9b-4468-1adb-b366-a068aec907ae@cogentembedded.com>
References: <cover.1502972068.git.aviad.krawczyk@huawei.com>
 <cae481edc7c9217cc61dbeb1f7eb642ba7a9dbfc.1502972069.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        bc.y@huawei.com, victor.gissin@huawei.com, zhaochen6@huawei.com,
        tony.qu@huawei.com
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cae481edc7c9217cc61dbeb1f7eb642ba7a9dbfc.1502972069.git.aviad.krawczyk@huawei.com>
Content-Language: en-MW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/17/2017 03:25 PM, Aviad Krawczyk wrote:

> Add more netdev operation - netpoll.
> 
> Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
> Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
> ---
>   MAINTAINERS                                    |  7 +++++++
>   drivers/net/ethernet/huawei/hinic/hinic_main.c | 20 ++++++++++++++++++++
>   2 files changed, 27 insertions(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 0e967b3..8f9ea9b 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6240,6 +6240,13 @@ L:	linux-input@vger.kernel.org
>   S:	Maintained
>   F:	drivers/input/touchscreen/htcpen.c
>   
> +HUAWEI ETHERNET DRIVER
> +M:	Aviad Krawczyk <aviad.krawczyk@huawei.com>
> +L:	netdev@vger.kernel.org
> +S:	Supported
> +F:	Documentation/networking/hinic.txt
> +F:	drivers/net/ethernet/huawei/hinic/
> +

    Sorry for not asking this question before: how is the new MAINTAINERS 
record related to the netpoll support? This should be in a separate patch.

[...]

MBR, Sergei
