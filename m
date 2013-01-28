From: David Miller <davem@davemloft.net>
Subject: Re: [patch] qlcnic: silence false positive overflow warning
Date: Sun, 27 Jan 2013 20:38:51 -0500 (EST)
Message-ID: <20130127.203851.2157088853751625559.davem@davemloft.net>
References: <20130125064141.GB4882@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756419Ab3A1Biy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 20:38:54 -0500
In-Reply-To: <20130125064141.GB4882@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 25 Jan 2013 09:41:42 +0300

> We actually store the MAC address as well as the board_name here.  The
> longest board_name is 75 characters so there is more than enough room
> to hold the 17 character MAC and the ": " divider.  But making this
> buffer larger silences a static checker warning.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

This patch doesn't apply cleanly to any of my trees.
