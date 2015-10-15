From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next V16 2/3] Check for vlan ethernet types for 8021.q
 or 802.1ad
Date: Thu, 15 Oct 2015 17:05:14 +0300
Message-ID: <561FB29A.4080101@cogentembedded.com>
References: <1444917715-27093-1-git-send-email-thomasfherbert@gmail.com>
 <1444917715-27093-3-git-send-email-thomasfherbert@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@redhat.com, dev@openvswitch.org
To: Thomas F Herbert <thomasfherbert@gmail.com>,
	netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:33893 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbbJOOFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 10:05:23 -0400
Received: by lfaz124 with SMTP id z124so28423235lfa.1
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 07:05:22 -0700 (PDT)
In-Reply-To: <1444917715-27093-3-git-send-email-thomasfherbert@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/2015 5:01 PM, Thomas F Herbert wrote:

    Hm, I'm seeing no sign-off on this patch.

> ---
>   include/linux/if_vlan.h | 16 ++++++++++++++++
>   1 file changed, 16 insertions(+)
>
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index 67ce5bd..ac23521 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -627,6 +627,22 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
>
>   	return features;
>   }
> +/**
> + * eth_type_vlan - check for valid vlan ether type.
> + * @ethertype: ether type to check
> + *
> + * Returns true if the ether type is a vlan ether type.
> + */
> +static inline bool eth_type_vlan(__be16 ethertype)
> +{
> +	switch (ethertype) {
> +	case (htons(ETH_P_8021Q)):
> +	case (htons(ETH_P_8021AD)):

    Hm, I thought you had a request to delete the outer parens already...

[...]

MBR, Sergei
