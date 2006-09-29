From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 6/7] secid reconciliation-v03: Label locally generated
 IPv4 traffic
Date: Fri, 29 Sep 2006 03:34:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609290333470.1650@d.namei>
References: <451C85EE.4030307@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:28294 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161474AbWI2Her (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 03:34:47 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <451C85EE.4030307@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Sep 2006, Venkat Yekkirala wrote:

> +static inline void security_skb_classify_ipcm(struct sk_buff *skb,
> +					struct ipcm_cookie *ipc)
> +{
> +	ipc->secid = 0;
> +	ipc->secid = skb->secmark;
> +}

You don't need the assignment to 0.



- James
-- 
James Morris
<jmorris@namei.org>
