From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] checkpatch.pl: Fix warnings on code comments
Date: Sun, 27 Jan 2013 18:59:10 -0500 (EST)
Message-ID: <20130127.185910.1743425400733006443.davem@davemloft.net>
References: <1359286539-18395-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: apw@canonical.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409Ab3A0X7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 18:59:14 -0500
In-Reply-To: <1359286539-18395-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 27 Jan 2013 03:35:39 -0800

> Produces warnings on code comments which follow the Linux coding style
> guide.  While the desired code comment style for networking my differ
> from the rest of the kernel, both styles should be permitted.

I was actually going to mention to you guys that I've been lackadasical
about enforcing the comment style I want with the Intel drivers.

That was a mistake, I should have enforced it strictly, as I do for
the other drivers and the core networking code, from the beginning.

And it's clearly a mistake if you feel the need to take out the very
checkpatch working that's meant to enforce this comment style in all
of the networking drivers and core.

Do not revert this, follow it's advice instead.
