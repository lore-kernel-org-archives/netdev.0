From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: netdev_kobject_init: annotate with __init
Date: Sun, 05 Jan 2014 20:28:17 -0500 (EST)
Message-ID: <20140105.202817.799324693682752406.davem@davemloft.net>
References: <1388967611-14263-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaAFB2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 20:28:23 -0500
In-Reply-To: <1388967611-14263-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  6 Jan 2014 01:20:11 +0100

> netdev_kobject_init() is only being called from __init context,
> that is, net_dev_init(), so annotate it with __init as well, thus
> the kernel can take this as a hint that the function is used only
> during the initialization phase and free up used memory resources
> after its invocation.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
