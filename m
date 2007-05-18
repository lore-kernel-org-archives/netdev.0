From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] netdevice ops
Date: Thu, 17 May 2007 21:49:35 -0700 (PDT)
Message-ID: <20070517.214935.27951232.davem@davemloft.net>
References: <20070517210737.17d88401@localhost>
	<464D2A34.5000303@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48362
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755695AbXEREtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 00:49:33 -0400
In-Reply-To: <464D2A34.5000303@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 17 May 2007 21:23:16 -0700

> Vlan code uses several of the methods, so I'm not sure how it will save 
> any memory

Feeling particularly dense today?

Only one copy of the ops will be needed for all vlan devices:

static const struct netdev_ops vlan_netdev_ops = {
	...
};

Then VLAN device creation goes, "vlan_netdev->ops = &vlan_netdev_ops;"

Clearer now?
