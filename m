From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] rds: spin_lock_irq() is not nestable
Date: Sun, 19 Sep 2010 12:00:07 -0700 (PDT)
Message-ID: <20100919.120007.28825179.davem@davemloft.net>
References: <20100918234414.GE6236@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.grover@oracle.com, zach.brown@oracle.com,
	chris.mason@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37832
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754006Ab0ISS7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Sep 2010 14:59:48 -0400
In-Reply-To: <20100918234414.GE6236@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sun, 19 Sep 2010 01:44:14 +0200

> This is basically just a cleanup.  IRQs were disabled on the previous
> line so we don't need to do it again here.  In the current code IRQs
> would get turned on one line earlier than intended.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Also applied, thanks Dan.
