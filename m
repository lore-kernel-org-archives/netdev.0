From: Joshua Brindle <method@gentoo.org>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Thu, 28 Sep 2006 23:52:55 -0400
Message-ID: <451C9897.6030306@gentoo.org>
References: <451C85F4.7000406@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov, paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tresys.irides.com ([216.250.243.126]:24435 "HELO
	exchange.columbia.tresys.com") by vger.kernel.org with SMTP
	id S1161103AbWI2DxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 23:53:25 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <451C85F4.7000406@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
> <snip>
> +
> +	err = avc_has_perm(xfrm_sid, skb->secmark, SECCLASS_PACKET,
> +					PACKET__FLOW_IN, NULL);
> +	if (err)
> +		goto out;
> +
> +	if (xfrm_sid) {
> +		err = security_transition_sid(xfrm_sid, skb->secmark,
> +						SECCLASS_PACKET, &trans_sid);
> +		if (err)
> +			goto out;
> +
>   
I thought we weren't doing transitions to label packets anymore per the 
conference call?
