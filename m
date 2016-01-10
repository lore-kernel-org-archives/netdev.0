From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net RESEND] udp: restrict offloads to one namespace
Date: Sun, 10 Jan 2016 17:28:41 -0500 (EST)
Message-ID: <20160110.172841.1484098968226039838.davem@davemloft.net>
References: <1452173319-13610-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, edumazet@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757589AbcAJW2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 17:28:44 -0500
In-Reply-To: <1452173319-13610-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu,  7 Jan 2016 14:28:39 +0100

> udp tunnel offloads tend to aggregate datagrams based on inner
> headers. gro engine gets notified by tunnel implementations about
> possible offloads. The match is solely based on the port number.
> 
> Imagine a tunnel bound to port 53, the offloading will look into all
> DNS packets and tries to aggregate them based on the inner data found
> within. This could lead to data corruption and malformed DNS packets.
> 
> While this patch minimizes the problem and helps an administrator to find
> the issue by querying ip tunnel/fou, a better way would be to match on
> the specific destination ip address so if a user space socket is bound
> to the same address it will conflict.
> 
> Cc: Tom Herbert <tom@herbertland.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Hannes.
