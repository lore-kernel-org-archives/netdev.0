From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] core: dev: don't call BUG() on bad input
Date: Mon, 14 Feb 2011 11:25:21 -0800 (PST)
Message-ID: <20110214.112521.104056910.davem@davemloft.net>
References: <1297694579-23611-1-git-send-email-segoon@openwall.com>
	<AANLkTimidxVJxw-XKTWwCZh8k_vKHDeqxAwVbY6+aJ6x@mail.gmail.com>
	<20110214152310.GA24429@albatros>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, therbert@google.com, xiaosuo@gmail.com,
	jesse@nicira.com, netdev@vger.kernel.org
To: segoon@openwall.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52098
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752638Ab1BNTYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 14:24:45 -0500
In-Reply-To: <20110214152310.GA24429@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasiliy Kulikov <segoon@openwall.com>
Date: Mon, 14 Feb 2011 18:23:10 +0300

> On Mon, Feb 14, 2011 at 17:16 +0200, Alexey Dobriyan wrote:
>> Netdevice name isn't some random junk you get from userspace, so BUG is fine.
> 
> It IS for bluetooth, see net/bluetooth/bnep/core.c: bnep_add_connection() and
> net/bluetooth/bnep/sock.c: bnep_sock_ioctl(). 

If bluetooth wants to allow something so foolish, then it's bluetooth's
responsibility to sanity check the arguments before blinding passing
them into kernel APIs which expect sane inputs.

I'm not applying this.
