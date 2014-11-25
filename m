From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v3 15/17] bridge: add new hwmode swdev
Date: Tue, 25 Nov 2014 08:03:11 -0800
Message-ID: <5474A83F.7040006@cumulusnetworks.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-16-git-send-email-jiri@resnulli.us>
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
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:45743 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbaKYQDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:03:37 -0500
In-Reply-To: <1416911328-10979-16-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14, 2:28 AM, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Current hwmode settings are "vepa" or "veb".  These are for NIC interfaces
> with basic bridging function offloaded to HW.  Add new "swdev" for full
> switch device offloads.

still voting for a generic feature flag like NETIF_F_HW_OFFLOAD for use 
by bridge/bond/vxlan. I can resubmit my patch that does this.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
> new in v3
> ---
>   include/uapi/linux/if_bridge.h | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
> index da17e45..60425ca 100644
> --- a/include/uapi/linux/if_bridge.h
> +++ b/include/uapi/linux/if_bridge.h
> @@ -105,6 +105,7 @@ struct __fdb_entry {
>   
>   #define BRIDGE_MODE_VEB		0	/* Default loopback mode */
>   #define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
> +#define BRIDGE_MODE_SWDEV       2       /* Full switch device offload */
>   
>   /* Bridge management nested attributes
>    * [IFLA_AF_SPEC] = {
