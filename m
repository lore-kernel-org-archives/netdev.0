From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] openvswitch: Fix incorrect type use.
Date: Wed, 21 Oct 2015 13:30:01 +0200
Message-ID: <20151021133001.5e5af057@griffin>
References: <1445399266-2034-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60470 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753956AbbJULaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2015 07:30:04 -0400
In-Reply-To: <1445399266-2034-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Oct 2015 20:47:46 -0700, Pravin B Shelar wrote:
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -548,11 +548,11 @@ static int ip_tun_from_nlattr(const struct nlattr *attr,
>  			      struct sw_flow_match *match, bool is_mask,
>  			      bool log)
>  {
> +	bool ttl = false, ipv4 = false, ipv6 = false;
> +	__be16 tun_flags = 0;
> +	int opts_type = 0;
>  	struct nlattr *a;
>  	int rem;
> -	bool ttl = false;
> -	__be16 tun_flags = 0, ipv4 = false, ipv6 = false;
> -	int opts_type = 0;

Seems that I appended the variables to a wrong line during one of the
rebases. Thanks for fixing this.

Acked-by: Jiri Benc <jbenc@redhat.com>

-- 
Jiri Benc
