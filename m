From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: mlx5: fix sizeof usage in health_care's
 reg_handler
Date: Sun, 04 Aug 2013 23:39:14 -0700 (PDT)
Message-ID: <20130804.233914.254272149071930357.davem@davemloft.net>
References: <1375438577-30933-1-git-send-email-dborkman@redhat.com>
	<20130802.151132.539136654627638979.davem@davemloft.net>
	<20130805063334.GA22386@mtldesk30>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, ogerlitz@mellanox.com
To: eli@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754725Ab3HEGjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 02:39:15 -0400
In-Reply-To: <20130805063334.GA22386@mtldesk30>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@dev.mellanox.co.il>
Date: Mon, 5 Aug 2013 09:33:34 +0300

> the intention here was to allow other module, if they so wish, to get
> notified of any problems detected at the device. I understand that you
> don't like this but is there another way to handle this requirement
> which will be accepted?

Which modules?  I do not see them.

Please remove this unused facility, now.
