From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/16] batman-adv: separate BATADV_ATTR_HIF_UINT sysfs
 name from hard-iface variable
Date: Sun, 28 Oct 2012 18:59:27 -0400 (EDT)
Message-ID: <20121028.185927.374901219739099234.davem@davemloft.net>
References: <1351423037-5292-1-git-send-email-ordex@autistici.org>
	<1351423037-5292-4-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	lindner_marek@yahoo.de
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43838 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754094Ab2J1W7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 18:59:40 -0400
In-Reply-To: <1351423037-5292-4-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Sun, 28 Oct 2012 12:17:04 +0100

> From: Marek Lindner <lindner_marek@yahoo.de>
> 
> Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
> Signed-off-by: Antonio Quartulli <ordex@autistici.org>
> ---
>  net/batman-adv/sysfs.c | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)

I was wondering how you could possibly change the list of arguments to
these macros, yet avoid changing any of the users.

And sure enough it's because these macros are completely unused.

Please just remove them instead of changing their interfaces when no
users exist.
