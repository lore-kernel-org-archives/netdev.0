From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED]: cls_fw: fix NULL pointer dereference
Date: Tue, 05 Dec 2006 13:46:37 -0800 (PST)
Message-ID: <20061205.134637.32347599.davem@davemloft.net>
References: <45744016.8080707@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S937161AbWLEVqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 16:46:31 -0500
To: kaber@trash.net
In-Reply-To: <45744016.8080707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 04 Dec 2006 16:34:46 +0100

> [NET_SCHED]: cls_fw: fix NULL pointer dereference
> 
> When the first fw classifier is initialized, there is a small window
> between the ->init() and ->change() calls, during which the classifier
> is active but not entirely set up and tp->root is still NULL (->init()
> does nothing).
> 
> When a packet is queued during this window a NULL pointer dereference
> occurs in fw_classify() when trying to dereference head->mask;
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

I've applied this, thanks Patrick.
