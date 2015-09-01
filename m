From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: send only one NEWLINK when RA causes changes
Date: Mon, 31 Aug 2015 21:23:15 -0700 (PDT)
Message-ID: <20150831.212315.1592958840555239823.davem@davemloft.net>
References: <20150831235706.GA17924@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mt@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbbIAEXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 00:23:18 -0400
In-Reply-To: <20150831235706.GA17924@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marius Tomaschewski <mt@suse.de>
Date: Tue, 1 Sep 2015 01:57:30 +0200

> Signed-off-by: Marius Tomaschewski <mt@suse.de>

Applied, thanks.

I wonder what to do about the situations right before the first
assignment of send_ifinfo_notify to true where the dst_neigh_lookup()
fails.

Since we updated if_flags, we probably should still emit the
notification.
