From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
Date: Sun, 16 Sep 2007 14:14:56 -0700
Message-ID: <20070916141456.32da6855.akpm@linux-foundation.org>
References: <20070911164033.GA3754@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, davem@davemloft.org, netdev@vger.kernel.org,
	baum@tehutinetworks.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36305 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751948AbXIPVPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 17:15:38 -0400
In-Reply-To: <20070911164033.GA3754@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

erp, changes in the net-2.6.24 tree breaks this.

drivers/net/tehuti.c: In function 'bdx_isr_napi':
drivers/net/tehuti.c:268: error: too few arguments to function 'netif_rx_schedule_prep'
drivers/net/tehuti.c:269: error: too few arguments to function '__netif_rx_schedule'
drivers/net/tehuti.c: In function 'bdx_poll':
drivers/net/tehuti.c:302: error: too few arguments to function 'netif_rx_complete'
drivers/net/tehuti.c: In function 'bdx_hw_start':
drivers/net/tehuti.c:414: error: implicit declaration of function 'netif_poll_enable'
drivers/net/tehuti.c: In function 'bdx_hw_stop':
drivers/net/tehuti.c:428: error: implicit declaration of function 'netif_poll_disable'
drivers/net/tehuti.c: In function 'bdx_rx_receive':
drivers/net/tehuti.c:1219: error: 'struct net_device' has no member named 'quota'
drivers/net/tehuti.c:1219: warning: type defaults to 'int' in declaration of '_y'
drivers/net/tehuti.c:1219: error: 'struct net_device' has no member named 'quota'
drivers/net/tehuti.c:1311: error: 'struct net_device' has no member named 'quota'
drivers/net/tehuti.c: In function 'bdx_probe':
drivers/net/tehuti.c:1994: error: 'struct net_device' has no member named 'poll'
drivers/net/tehuti.c:1995: error: 'struct net_device' has no member named 'weight'
drivers/net/tehuti.c:2058: error: implicit declaration of function 'SET_MODULE_OWNER'

There's a lot of churn in networking at present and I don't have time/inclination
to fix this one up, sorry.
