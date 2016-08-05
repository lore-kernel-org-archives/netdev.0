From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC V2 PATCH 04/25] net/netpolicy: get CPU information
Date: Fri, 5 Aug 2016 14:00:32 +0300
Message-ID: <675652db-6d35-783f-1745-6e6b932ed868@cogentembedded.com>
References: <1470339389-8542-1-git-send-email-kan.liang@intel.com>
 <1470339389-8542-5-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mingo@redhat.com, peterz@infradead.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org
To: kan.liang@intel.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470339389-8542-5-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 8/4/2016 10:36 PM, kan.liang@intel.com wrote:

> From: Kan Liang <kan.liang@intel.com>
>
> Net policy also needs to know CPU information. Currently, online
> CPU number is enough.

    s/number/count/. Or "the number of online CPUs".

>
> Signed-off-by: Kan Liang <kan.liang@intel.com>
> ---
>  net/core/netpolicy.c | 5 +++++
>  1 file changed, 5 insertions(+)
>
> diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
> index 7c34c8a..075aaca 100644
> --- a/net/core/netpolicy.c
> +++ b/net/core/netpolicy.c
> @@ -49,6 +49,11 @@ static void netpolicy_free_dev_info(struct netpolicy_dev_info *d_info)
>  	kfree(d_info->tx_irq);
>  }
>
> +static u32 netpolicy_get_cpu_information(void)
> +{
> +	return num_online_cpus();
> +}
> +
>  const char *policy_name[NET_POLICY_MAX] = {
>  	"NONE"
>  };

MBR, Sergei
