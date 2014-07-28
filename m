From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc-ether: clean packet filter upon probe
Date: Sun, 27 Jul 2014 22:30:13 -0700 (PDT)
Message-ID: <20140727.223013.144325831197355256.davem@davemloft.net>
References: <1406202989-8047-1-git-send-email-oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbaG1FaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 01:30:16 -0400
In-Reply-To: <1406202989-8047-1-git-send-email-oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Thu, 24 Jul 2014 13:56:29 +0200

> +			1000 /* out of thin air */

Just use USB_CTRL_SET_TIMEOUT if you can't come up with a specific
reason to use another value.

Thanks.
