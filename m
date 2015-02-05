From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 02/29] net: Flip net_device to use net_ctx
Date: Thu, 05 Feb 2015 14:47:20 +0100
Message-ID: <54D37468.6040508@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <1423100070-31848-3-git-send-email-dsahern@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:51473 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbbBENrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:47:23 -0500
Received: by mail-we0-f176.google.com with SMTP id w62so7767589wes.7
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 05:47:22 -0800 (PST)
In-Reply-To: <1423100070-31848-3-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
> +static inline
> +int dev_net_ctx_eq(const struct net_device *dev, struct net_ctx *ctx=
)
> +{
> +	if (net_eq(dev_net(dev), ctx->net))
> +		return 1;
Why not using net_ctx_eq()?
