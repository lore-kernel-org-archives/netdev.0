From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 1/7] bnx2: don't request firmware when there's no
 userspace.
Date: Mon, 03 Oct 2011 14:09:23 -0400 (EDT)
Message-ID: <20111003.140923.810769639543301700.davem@davemloft.net>
References: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
	<20110930103652.GB26727@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755258Ab1JCSKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 14:10:33 -0400
In-Reply-To: <20110930103652.GB26727@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 30 Sep 2011 12:36:52 +0200

> The firmware is cached during the first successful call to open() and
> released once the network device is unregistered. The driver uses the
> cached firmware between open() and unregister_netdev().
> 
> It's similar to 953a12cc2889d1be92e80a2d0bab5ffef4942300 but the
> firmware is mandatory.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Reviewed-by: Michael Chan <mchan@broadcom.com>

Applied.
