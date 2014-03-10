From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: eth: cpsw: Use net_device_stats from struct net_device
Date: Mon, 10 Mar 2014 17:52:16 +0530
Message-ID: <531DAE78.2030302@ti.com>
References: <1394453543-30094-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Siewior <bigeasy@linutronix.de>, <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:40485 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753053AbaCJMWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Mar 2014 08:22:25 -0400
In-Reply-To: <1394453543-30094-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 March 2014 05:42 PM, Tobias Klauser wrote:
> Instead of using an own copy of struct net_device_stats in struct
> cpsw_priv, use stats from struct net_device. Also remove the thus
> unnecessary .ndo_get_stats function, as it just returns dev->stats,
> which is the default.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Looks good to me.
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
