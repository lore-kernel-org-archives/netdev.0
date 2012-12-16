From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: jsctp_sf_eat_sack: fix jprobes function
 signature mismatch
Date: Sat, 15 Dec 2012 17:17:04 -0800 (PST)
Message-ID: <20121215.171704.680026100055391698.davem@davemloft.net>
References: <cover.1355602097.git.dborkman@redhat.com>
	<a910a63d58d95aed8caeea8a43a21cab863b3bfb.1355602097.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926Ab2LPBRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2012 20:17:04 -0500
In-Reply-To: <a910a63d58d95aed8caeea8a43a21cab863b3bfb.1355602097.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat, 15 Dec 2012 21:12:43 +0100

> Commit 24cb81a6a (sctp: Push struct net down into all of the
> state machine functions) introduced the net structure into all
> state machine functions, but jsctp_sf_eat_sack was not updated,
> hence when SCTP association probing is enabled in the kernel,
> any simple SCTP client/server program from userspace will panic
> the kernel.
> 
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
