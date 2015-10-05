From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fix reply_dst leakage on arp reply
Date: Mon, 05 Oct 2015 04:05:50 -0700 (PDT)
Message-ID: <20151005.040550.1057028673382250394.davem@davemloft.net>
References: <7d4263830abc45f0a1cea8aebcbc7c56debb4270.1443709468.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39169 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbbJEKuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 06:50:10 -0400
In-Reply-To: <7d4263830abc45f0a1cea8aebcbc7c56debb4270.1443709468.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu,  1 Oct 2015 16:25:43 +0200

> There are cases when the created metadata reply is not used. Ensure the
> allocated memory is freed also in such cases.
> 
> Fixes: 63d008a4e9ee ("ipv4: send arp replies to the correct tunnel")
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.
