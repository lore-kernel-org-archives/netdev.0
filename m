From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH V2 net-next 21/21] net-next/hinic: Add select_queue and
 netpoll
Date: Wed, 19 Jul 2017 14:34:24 +0300
Message-ID: <139781f1-8770-2f6d-81c2-b2d411cfeac5@cogentembedded.com>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
 <b5fb082d3a35a261c230313421ba16f3e9595dbe.1500454998.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        bc.y@huawei.com, victor.gissin@huawei.com, zhaochen6@huawei.com,
        tony.qu@huawei.com
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b5fb082d3a35a261c230313421ba16f3e9595dbe.1500454998.git.aviad.krawczyk@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/19/2017 12:19 PM, Aviad Krawczyk wrote:

> Add more netdev operations.
> 
> Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
> Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
> ---
>   MAINTAINERS                                    |  7 ++++++
>   drivers/net/ethernet/huawei/hinic/hinic_main.c | 35 ++++++++++++++++++++++++++
>   2 files changed, 42 insertions(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 1347726..5c85602 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6269,6 +6269,13 @@ L:	linux-input@vger.kernel.org
>   S:	Maintained
>   F:	drivers/input/touchscreen/htcpen.c
>   
> +HUAWEI ETHERNET DRIVER
> +M:	Aviad Krawczyk <aviad.krawczyk@huawei.com>
> +L:	netdev@vger.kernel.org
> +S:	Supported
> +F:	Documentation/networking/hinic.txt
> +F:	drivers/net/ethernet/huawei/*

    This means that subdirs there are not maintained, did you really mean it?

[...]

MNR, Sergei
