From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 7/9] snet: introduce snet_netlink.c and snet_netlink.h
Date: Sun, 17 Jan 2010 06:42:48 +0100
Message-ID: <m2ocktffs7.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-8-git-send-email-sam@synack.fr>
	<4B420464.3040301@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bob75-7-88-160-5-175.fbx.proxad.net ([88.160.5.175]:46808 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab0AQFmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 00:42:51 -0500
In-Reply-To: <4B420464.3040301@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 16:08:20 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Samir Bellabes wrote:
>> +	skb_rsp = genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
>> +	if (skb_rsp == NULL)
>> +		return 0;
>
> You could decrease the chance of rcvqueue overflow by using a smaller
> allocation size.

I took care of this by calculating the exact needed size.

thanks,
sam
