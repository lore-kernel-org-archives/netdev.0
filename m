From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v3 14/17] bridge: add new brport flag LEARNING_SYNC
Date: Tue, 25 Nov 2014 08:05:03 -0800
Message-ID: <5474A8AF.4080007@cumulusnetworks.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-15-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45960 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbaKYQFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:05:17 -0500
In-Reply-To: <1416911328-10979-15-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14, 2:28 AM, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> This policy flag controls syncing of learned FDB entries to bridge's FDB.  If
> on, FDB entries learned on bridge port device will be synced.  If off, device
> may still learn new FDB entries but they will not be synced with bridge's FDB.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Roopa Prabhu<roopa@cumulusnetworks.com>


> ---
> new in v3
> ---
>   include/linux/if_bridge.h    | 1 +
>   include/uapi/linux/if_link.h | 1 +
>   2 files changed, 2 insertions(+)
>
> diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
> index b4bb104..67b7a8e 100644
> --- a/include/linux/if_bridge.h
> +++ b/include/linux/if_bridge.h
> @@ -42,6 +42,7 @@ struct br_ip_list {
>   #define BR_AUTO_MASK (BR_FLOOD | BR_LEARNING)
>   #define BR_PROMISC		0x00000080
>   #define BR_PROXYARP		0x00000100
> +#define BR_LEARNING_SYNC	0x00000200
>   
>   extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
>   
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 4163753..d8e6a31 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -245,6 +245,7 @@ enum {
>   	IFLA_BRPORT_LEARNING,	/* mac learning */
>   	IFLA_BRPORT_UNICAST_FLOOD, /* flood unicast traffic */
>   	IFLA_BRPORT_PROXYARP,	/* proxy ARP */
> +	IFLA_BRPORT_LEARNING_SYNC, /* mac learning sync from device */
>   	__IFLA_BRPORT_MAX
>   };
>   #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
