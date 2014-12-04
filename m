From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 5/6] link: add missing IFLA_BRPORT_PROXYARP
Date: Thu, 4 Dec 2014 10:53:59 -0800
Message-ID: <20141204105359.0fbd5b69@urahara>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
	<1417683438-10935-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:54900 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932464AbaLDSyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 13:54:21 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so18649549pad.10
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 10:54:21 -0800 (PST)
In-Reply-To: <1417683438-10935-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  4 Dec 2014 09:57:17 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Scott Feldman <sfeldma@gmail.com>
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/linux/if_link.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index a6e2594..06efa2d 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -242,6 +242,7 @@ enum {
>  	IFLA_BRPORT_FAST_LEAVE,	/* multicast fast leave    */
>  	IFLA_BRPORT_LEARNING,	/* mac learning */
>  	IFLA_BRPORT_UNICAST_FLOOD, /* flood unicast traffic */
> +	IFLA_BRPORT_PROXYARP,   /* proxy ARP */
>  	__IFLA_BRPORT_MAX
>  };
>  #define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)

Unnecessary patch since I pick up headers from upstream.
Already on net-next branch.
