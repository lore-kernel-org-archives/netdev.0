From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH 3/7] ieee802154: 6lowpan: make header_ops const
Date: Fri, 25 Aug 2017 16:36:37 +0200
Message-ID: <c9ada435-af29-c5e0-b72d-374199f6b6f9@osg.samsung.com>
References: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
 <1503670907-23221-4-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Bhumika Goyal <bhumirks@gmail.com>, julia.lawall@lip6.fr,
        marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        davem@davemloft.net, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        fw@strlen.de, stephen@networkplumber.org, alex.aring@gmail.com,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        santosh.shilimkar@oracle.com, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, linux-bluetooth@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        bridge@lists.linux-foundation.org, linux-wpan@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-nfs@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1503670907-23221-4-git-send-email-bhumirks@gmail.com>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/25/2017 04:21 PM, Bhumika Goyal wrote:
> Make this const as it is only stored as a reference in a const field of
> a net_device structure.
> 
> Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
> ---
>   net/ieee802154/6lowpan/core.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
> index de2661c..974765b 100644
> --- a/net/ieee802154/6lowpan/core.c
> +++ b/net/ieee802154/6lowpan/core.c
> @@ -54,7 +54,7 @@
>   
>   static int open_count;
>   
> -static struct header_ops lowpan_header_ops = {
> +static const struct header_ops lowpan_header_ops = {
>   	.create	= lowpan_header_create,
>   };
>   
> 

Acked-by: Stefan Schmidt <stefan@osg.samsung.com>

regards
Stefan Schmidt
