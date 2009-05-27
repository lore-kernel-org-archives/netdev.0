From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] Bugfix: xt_hashlimit does a wrong SEQ_SKIP.
Date: Wed, 27 May 2009 15:46:46 +0200
Message-ID: <4A1D4446.2060106@trash.net>
References: <20090526131852.7377.68330.stgit@localhost> <20090526131857.7377.6946.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50281 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756414AbZE0Nqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 09:46:49 -0400
In-Reply-To: <20090526131857.7377.6946.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer wrote:
> (Inside net/netfilter/xt_hashlimit.c)
> The function dl_seq_show() returns 1 (equal to SEQ_SKIP) in case
> a seq_printf() call return -1.  It should return -1.
> 
> This SEQ_SKIP behavior brakes processing the proc file e.g. via a
> pipe or just through less.

Applied patch 2/2, thanks.
