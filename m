From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 3/5] [NET]: Protocol Independant Policy Routing Rules
 Framework
Date: Thu, 27 Jul 2006 01:58:58 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607270158001.4779@d.namei>
References: <20060726221100.325687073@postel.suug.ch> <20060726221849.807482409@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:44737 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932484AbWG0F7B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 01:59:01 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060726221849.807482409@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Jul 2006, Thomas Graf wrote:

> +	rule = kmalloc(ops->rule_size, GFP_KERNEL);
> +	if (rule == NULL) {
> +		err = -ENOMEM;
> +		goto errout;
> +	}
> +	memset(rule, 0, ops->rule_size);
> +

kzalloc() ? :-)



- James
-- 
James Morris
<jmorris@namei.org>
