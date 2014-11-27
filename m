From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [patch net-next v4 13/21] bridge: add new hwmode swdev
Date: Thu, 27 Nov 2014 16:31:36 +0300
Message-ID: <547727B8.4040202@cogentembedded.com>
References: <1417084826-9875-1-git-send-email-jiri@resnulli.us> <1417084826-9875-14-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:53296 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbaK0Nbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 08:31:40 -0500
Received: by mail-lb0-f175.google.com with SMTP id u10so4060289lbd.20
        for <netdev@vger.kernel.org>; Thu, 27 Nov 2014 05:31:39 -0800 (PST)
In-Reply-To: <1417084826-9875-14-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/27/2014 1:40 PM, Jiri Pirko wrote:

> From: Scott Feldman <sfeldma@gmail.com>

> Current hwmode settings are "vepa" or "veb".  These are for NIC interfaces
> with basic bridging function offloaded to HW.  Add new "swdev" for full
> switch device offloads.

> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
> v3->v4:
> -no change
> new in v3
> ---
>   include/uapi/linux/if_bridge.h | 1 +
>   1 file changed, 1 insertion(+)

> diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
> index da17e45..60425ca 100644
> --- a/include/uapi/linux/if_bridge.h
> +++ b/include/uapi/linux/if_bridge.h
> @@ -105,6 +105,7 @@ struct __fdb_entry {
>
>   #define BRIDGE_MODE_VEB		0	/* Default loopback mode */
>   #define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
> +#define BRIDGE_MODE_SWDEV       2       /* Full switch device offload */

    Please use tabs for indentation.

[...]

WBR, Sergei
