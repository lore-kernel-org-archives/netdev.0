From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] driver: net: smsc911x: set NOCARRIER flag in
 driver initialization
Date: Fri, 30 May 2014 13:42:45 -0700 (PDT)
Message-ID: <20140530.134245.1805237850303710369.davem@davemloft.net>
References: <5380EAF6.1090402@gmail.com>
	<20140529.152809.871745461296745132.davem@davemloft.net>
	<CAHPKR9KmDSgC9EstJLfhqY9SB462OSJhQCEPS7Ka=VvnqbH6iQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933857AbaE3Umt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 16:42:49 -0400
In-Reply-To: <CAHPKR9KmDSgC9EstJLfhqY9SB462OSJhQCEPS7Ka=VvnqbH6iQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Fri, 30 May 2014 18:35:43 +0530

> All these drivers call netif_carrier_off function after registering
> the network device using register_netdev.

I can quote more counter-examples than your list, starting with the
Broadcom tg3 driver.
