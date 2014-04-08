From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: export phy_suspend and phy_resume
Date: Tue, 08 Apr 2014 12:29:53 -0400 (EDT)
Message-ID: <20140408.122953.1708326631498329706.davem@davemloft.net>
References: <20140408071101.GA14453@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tobias@waldekranz.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124AbaDHQ3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 12:29:55 -0400
In-Reply-To: <20140408071101.GA14453@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Waldekranz <tobias@waldekranz.com>
Date: Tue, 8 Apr 2014 09:11:01 +0200

> These functions are exported in include/linux/phy.h but the symbol
> exports where missing.
> 
> Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>

Because they are only used in places where module exports are unnecessary.
Presence in foo.h does not automatically mean the symbol should be
exported to modules.

If you come up with a use case that requires the module export, submit
it along with a patch like this.

But for now I'm not applying this, sorry.
