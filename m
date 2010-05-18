From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net-2.6 : fix dev_get_valid_name
Date: Tue, 18 May 2010 10:54:51 -0700
Message-ID: <20100518105451.05b060e8@nehalam>
References: <1274204112-8920-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, opurdila@ixiacom.com, netdev@vger.kernel.org
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34446 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932083Ab0ERRy5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 13:54:57 -0400
In-Reply-To: <1274204112-8920-1-git-send-email-daniel.lezcano@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 May 2010 19:35:12 +0200
Daniel Lezcano <daniel.lezcano@free.fr> wrote:

> +static int dev_get_valid_name(struct net_device *dev, const char *name, bool fmt)
>  {
> +	struct net *net;
> +
> +	BUG_ON(!dev_net(dev));
> +	net = dev_net(dev);

This is not really part of the same fix. And not sure why it is added here?

-- 
