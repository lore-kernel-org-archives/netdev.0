From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] core: dev: don't call BUG() on bad input
Date: Mon, 14 Feb 2011 11:36:45 -0800 (PST)
Message-ID: <20110214.113645.189699477.davem@davemloft.net>
References: <20110214152310.GA24429@albatros>
	<20110214.112521.104056910.davem@davemloft.net>
	<AANLkTimK5bW6HCjpttP0dkNnMLAU4msSd_VijAxAUcqO@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: segoon@openwall.com, adobriyan@gmail.com,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	xiaosuo@gmail.com, jesse@nicira.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45248
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751026Ab1BNTgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 14:36:09 -0500
In-Reply-To: <AANLkTimK5bW6HCjpttP0dkNnMLAU4msSd_VijAxAUcqO@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 14 Feb 2011 11:33:29 -0800

> On Mon, Feb 14, 2011 at 11:25 AM, David Miller <davem@davemloft.net> wrote:
>> From: Vasiliy Kulikov <segoon@openwall.com>
>> Date: Mon, 14 Feb 2011 18:23:10 +0300
>>
>>> On Mon, Feb 14, 2011 at 17:16 +0200, Alexey Dobriyan wrote:
>>>> Netdevice name isn't some random junk you get from userspace, so BUG is fine.
>>>
>>> It IS for bluetooth, see net/bluetooth/bnep/core.c: bnep_add_connection() and
>>> net/bluetooth/bnep/sock.c: bnep_sock_ioctl().
>>
>> If bluetooth wants to allow something so foolish, then it's bluetooth's
>> responsibility to sanity check the arguments before blinding passing
>> them into kernel APIs which expect sane inputs.
>>
>> I'm not applying this.
>>
> 
> Changing to BUG_ON(txqs < 1) and BUG_ON(rxqs < 1) does make sense I think.

Sure.
