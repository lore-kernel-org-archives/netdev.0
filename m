From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [1/1] netchannel subsystem.
Date: Mon, 15 May 2006 23:57:12 -0700 (PDT)
Message-ID: <20060515.235712.26771832.davem@davemloft.net>
References: <200605051248.42662.kelly@au.ibm.com>
	<200605161102.29472.kelly@au.ibm.com>
	<20060516061909.GA28670@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kelly@au1.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6584
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751573AbWEPG5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 02:57:08 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060516061909.GA28670@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 16 May 2006 10:19:09 +0400

> +static int netchannel_convert_skb_ipv4(struct sk_buff *skb, struct unetchannel *unc)
> +{
 ...
> +	switch (unc->proto) {
> +		case IPPROTO_TCP:
 ...
> +		case IPPROTO_UDP:
 ...

Why do people write code like this?

Port location is protocol agnostic, there are always 2
16-bit ports at beginning of header without exception.

Without this, ICMP would be useless :-)
