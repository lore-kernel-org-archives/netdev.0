From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]&[Question] netdevice: Use netdev_priv()
Date: Fri, 01 Aug 2008 03:24:24 -0700 (PDT)
Message-ID: <20080801.032424.114777556.davem@davemloft.net>
References: <4892DC57.2060101@cn.fujitsu.com>
	<20080801.030834.245436720.davem@davemloft.net>
	<4892E280.8050907@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58578
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751142AbYHAKYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 06:24:24 -0400
In-Reply-To: <4892E280.8050907@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 01 Aug 2008 18:16:32 +0800

> Then next question comes.
> We *have to* convert the drivers to use netdev_priv(), right?

No, we don't.

> Because, netdev->priv == netdev_priv() maybe change again in future,
> just as before.

We will work to prevent that.  I should not have allowed it to happen
in the first place. :-)
