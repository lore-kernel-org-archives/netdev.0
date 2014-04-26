From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC net-next 1/4] net: ipv6: Introduce flowi6_init_output.
Date: Sat, 26 Apr 2014 08:56:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1404260850030.1554@ja.home.ssi.bg>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com> <1398487705-13430-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	davem@davemloft.net, jpa@google.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33096 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750718AbaDZF4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Apr 2014 01:56:41 -0400
In-Reply-To: <1398487705-13430-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 26 Apr 2014, Lorenzo Colitti wrote:

> +static inline void flowi6_init_output(struct flowi6 *fl6, int oif,
> +				      __u32 mark, __u8 proto, __u8 flags,
> +				      __be32 flowlabel,
> +				      struct in6_addr daddr,
> +				      struct in6_addr saddr,
> +				      __be16 dport, __be16 sport)
> +{
> +	fl6->flowi6_oif = oif;
> +	fl6->flowi6_iif = 0;

	Make sure LOOPBACK_IFINDEX is provided in
flowi6_iif instead of 0, recent commit fixed such
FIB rule lookups.

Regards

--
Julian Anastasov <ja@ssi.bg>
