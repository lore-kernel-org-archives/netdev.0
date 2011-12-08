From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] add netpoll support for 802.1q vlans
Date: Thu, 08 Dec 2011 00:07:30 -0500 (EST)
Message-ID: <20111208.000730.63159506168958262.davem@davemloft.net>
References: <20111207010424.GA16496@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab1LHFHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 00:07:33 -0500
In-Reply-To: <20111207010424.GA16496@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 6 Dec 2011 20:04:24 -0500

> Add netpoll support to 802.1q vlan devices.  Based on the netpoll support 
> in the bridging code.  Tested on a forced_eth device with netconsole.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Bridging doesn't try to invoke a downstream netpoll operation at all,
and neither should you.

Also, please format your subject line correctly so I don't have to edit
it when applying your patch.  You need to add an appropriate, lowercase,
subsystem prefix after the [PATCH] tag otherwise people scanning the
shortlog in GIT can't figure out what area your patch is in.

In this situation "vlan: " might be appropriate.
