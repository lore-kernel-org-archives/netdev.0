From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev_adjacent_sysfs_*: fix cross-namespace symlinks
Date: Fri, 22 Aug 2014 11:30:39 -0700 (PDT)
Message-ID: <20140822.113039.520798752693024139.davem@davemloft.net>
References: <20140821191316.27807ef7@mad-cat.int.e5.ru>
	<20140821152940.GT9476@redhat.com>
	<1408703693-6265-1-git-send-email-git.user@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@redhat.com
To: git.user@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52938 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932735AbaHVSak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 14:30:40 -0400
In-Reply-To: <1408703693-6265-1-git-send-email-git.user@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexander Y. Fomichev" <git.user@gmail.com>
Date: Fri, 22 Aug 2014 14:34:53 +0400

> fix code manipulating symlinks of adjacent net devices.
> - prevent creation of sysfs symlink to / from adjacent device on
>   another net_ns.
> - Drop all existing symlinks from / to all adj_dev(s) on the current
>   namespace before switching net_ns and recreate them just after.

Please resubmit this with a proper Signed-off-by tag.
