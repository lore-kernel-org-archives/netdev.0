From: David Miller <davem@davemloft.net>
Subject: Re: [Linux-ATM-General] [PATCH] atm/br2684: netif_stop_queue()
 when atm device busy and netif_wake_queue() when we can send packets again.
Date: Fri, 11 Sep 2009 11:48:48 -0700 (PDT)
Message-ID: <20090911.114848.177667600.davem@davemloft.net>
References: <1251545092-18081-1-git-send-email-karl@hiramoto.org>
	<4AA95838.4010007@redfish-solutions.com>
	<4AA97004.2010904@hiramoto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: philipp_subx@redfish-solutions.com, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net
To: karl@hiramoto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54040
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755893AbZIKSsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 14:48:31 -0400
In-Reply-To: <4AA97004.2010904@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Hiramoto <karl@hiramoto.org>
Date: Thu, 10 Sep 2009 23:30:44 +0200

> I'm not really sure if or how many packets to upper layers buffer.

This is determined by ->tx_queue_len, so whatever value is being
set for ATM network devices is what the core will use for backlog
limiting while the device's TX queue is stopped.
