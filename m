From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Fri, 3 Jul 2015 11:49:18 +0200
Message-ID: <20150703094918.GG26182@pox.localdomain>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38801 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754752AbbGCKLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 06:11:13 -0400
Received: by wibdq8 with SMTP id dq8so96082314wib.1
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 03:11:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/15 at 09:49pm, Roopa Prabhu wrote:
> +static inline struct lwtunnel_state *lwtunnel_skb_lwstate(struct sk_buff *skb)
> +{
> +	struct rtable *rt = (struct rtable *)skb_dst(skb);
> +
> +	return rt->rt_lwtstate;
> +}

Noticed while rebasing onto your patches. This needs an
ifdef CONFIG_LWTUNNEL.
