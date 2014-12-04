From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Thu, 04 Dec 2014 08:17:22 -0500
Message-ID: <54805EE2.8000302@mojatatu.com>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us> <1417683438-10935-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:58655 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819AbaLDNR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 08:17:27 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so18636580igb.13
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 05:17:27 -0800 (PST)
In-Reply-To: <1417683438-10935-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/14 03:57, Jiri Pirko wrote:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   include/linux/if_link.h | 1 +
>   ip/ipaddress.c          | 8 ++++++++
>   2 files changed, 9 insertions(+)
>
> diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> index 4732063..a6e2594 100644
> --- a/include/linux/if_link.h
> +++ b/include/linux/if_link.h
> @@ -145,6 +145,7 @@ enum {
>   	IFLA_CARRIER,
>   	IFLA_PHYS_PORT_ID,
>   	IFLA_CARRIER_CHANGES,
> +	IFLA_PHYS_SWITCH_ID,
>   	__IFLA_MAX
>   };
>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
