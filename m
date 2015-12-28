From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: label accepted/peeled off sockets
Date: Mon, 28 Dec 2015 00:15:07 -0500 (EST)
Message-ID: <20151228.001507.1371766476900238868.davem@davemloft.net>
References: <339eee4a8d20118f871fda8a8b38591a60bea59b.1450895942.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cluster-devel@redhat.com,
	pmoore@redhat.com, teigland@redhat.com, nhorman@tuxdriver.com,
	vyasevich@gmail.com
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbbL1FPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 00:15:09 -0500
In-Reply-To: <339eee4a8d20118f871fda8a8b38591a60bea59b.1450895942.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Wed, 23 Dec 2015 16:44:09 -0200

> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 
> Accepted or peeled off sockets were missing a security label (e.g.
> SELinux) which means that socket was in "unlabeled" state.
> 
> This patch clones the sock's label from the parent sock and resolves the
> issue (similar to AF_BLUETOOTH protocol family).
> 
> Cc: Paul Moore <pmoore@redhat.com>
> Cc: David Teigland <teigland@redhat.com>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
