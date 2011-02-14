From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2] core: dev: don't call BUG() on bad input
Date: Mon, 14 Feb 2011 11:33:29 -0800
Message-ID: <AANLkTimK5bW6HCjpttP0dkNnMLAU4msSd_VijAxAUcqO@mail.gmail.com>
References: <1297694579-23611-1-git-send-email-segoon@openwall.com>
	<AANLkTimidxVJxw-XKTWwCZh8k_vKHDeqxAwVbY6+aJ6x@mail.gmail.com>
	<20110214152310.GA24429@albatros>
	<20110214.112521.104056910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: segoon@openwall.com, adobriyan@gmail.com,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	xiaosuo@gmail.com, jesse@nicira.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110214.112521.104056910.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 14, 2011 at 11:25 AM, David Miller <davem@davemloft.net> wrote:
> From: Vasiliy Kulikov <segoon@openwall.com>
> Date: Mon, 14 Feb 2011 18:23:10 +0300
>
>> On Mon, Feb 14, 2011 at 17:16 +0200, Alexey Dobriyan wrote:
>>> Netdevice name isn't some random junk you get from userspace, so BUG is fine.
>>
>> It IS for bluetooth, see net/bluetooth/bnep/core.c: bnep_add_connection() and
>> net/bluetooth/bnep/sock.c: bnep_sock_ioctl().
>
> If bluetooth wants to allow something so foolish, then it's bluetooth's
> responsibility to sanity check the arguments before blinding passing
> them into kernel APIs which expect sane inputs.
>
> I'm not applying this.
>

Changing to BUG_ON(txqs < 1) and BUG_ON(rxqs < 1) does make sense I think.

Tom
