From: yshi <yang.shi@windriver.com>
Subject: Re: [PATCH] Improvev netconsole support for RTL8139 NIC driver
Date: Wed, 26 Mar 2008 10:52:28 +0800
Message-ID: <47E9BA6C.2010502@windriver.com>
References: <47E9B115.9060109@windriver.com>	<47E9B39C.5010502@pobox.com> <20080325.194221.16658596.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37573 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727AbYCZCw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 22:52:28 -0400
In-Reply-To: <20080325.194221.16658596.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller =E5=86=99=E9=81=93:
> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Tue, 25 Mar 2008 22:23:24 -0400
>
>  =20
>> This is bogus -- you should never need to slow down the hot path in =
such=20
>> a way.
>>    =20
>
> Slow down in what way?  Even on x86 saving the flags is just
> about as expensive as a plain sti/cli.
>
> I would in fact prefer to see drivers unconditionally use
> spin_lock_irqsave() et al. in the interrupt handler, for
> consistency.
>  =20
Yes, I agree. Many NIC drivers do the same thing, like Gianfar, E1000, =
etc.

