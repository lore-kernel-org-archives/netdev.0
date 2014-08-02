From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8152: correct error returns
Date: Sat, 02 Aug 2014 16:34:18 -0700 (PDT)
Message-ID: <20140802.163418.1314777407262254543.davem@davemloft.net>
References: <1406901370-6847-1-git-send-email-oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaHBXeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Aug 2014 19:34:19 -0400
In-Reply-To: <1406901370-6847-1-git-send-email-oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Fri,  1 Aug 2014 15:56:10 +0200

> If an autoresume fails the internal error codes of the PM
> subsystem mustn't be leaked to user space. Replace them by EIO
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Really?

Then even the core usbnet driver gets this wrong, as well as many
other drivers I scanned over for this problem.
