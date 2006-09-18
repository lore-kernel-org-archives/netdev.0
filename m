From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 6/7] secid reconciliation-v02: Label locally generated
 IPv4 traffic
Date: Mon, 18 Sep 2006 14:12:36 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609181412150.5976@d.namei>
References: <45019F6F.9090500@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:5308 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751869AbWIRSMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 14:12:38 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <45019F6F.9090500@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 8 Sep 2006, Venkat Yekkirala wrote:

> diff --git a/include/net/ip.h b/include/net/ip.h
> index 98f9084..4646c13 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -48,6 +48,9 @@ struct ipcm_cookie
> 	u32			addr;
> 	int			oif;
> 	struct ip_options	*opt;
> +#ifdef CONFIG_SECURITY_NETWORK
> +	__u32			secid;
> +#endif /* CONFIG_SECURITY_NETWORK */
> };

This field should be 'u32'.


-- 
James Morris
<jmorris@namei.org>
