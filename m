From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] bonding: add slave_changelink support and use
 it for queue_id
Date: Wed, 27 Aug 2014 16:29:57 +0200
Message-ID: <20140827142957.GA1908@nanopsycho.lan>
References: <1409148406-5576-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:56333 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934508AbaH0OaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 10:30:04 -0400
Received: by mail-wg0-f44.google.com with SMTP id m15so291229wgh.15
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 07:30:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1409148406-5576-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 27, 2014 at 04:06:46PM CEST, nikolay@redhat.com wrote:
>This patch adds support for slave_changelink to the bonding and uses it
>to give the ability to change the queue_id of the enslaved devices via
>netlink. It sets slave_maxtype and uses bond_changelink as a prototype for
>bond_slave_changelink.
>Example/test command after the iproute2 patch:
> ip link set eth0 type bond_slave queue_id 10
>
>CC: David S. Miller <davem@davemloft.net>
>CC: Jay Vosburgh <j.vosburgh@gmail.com>
>CC: Veaceslav Falico <vfalico@gmail.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>
>Suggested-by: Jiri Pirko <jiri@resnulli.us>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>---
>note: I intend to add a new option flag to indicate it's a slave option
>      so a new netdev notifier can be called (NETDEV_CHANGESLAVEINFODATA).

	No need fo that atm.

>      I believe the bonding is the first user of slave_changelink so I hope
>      I haven't missed anything. Once this patch is accepted in some form
>      I'll post the iproute2 one.


This patch is looking good to me.

Acked-by: Jiri Pirko <jiri@resnulli.us>
