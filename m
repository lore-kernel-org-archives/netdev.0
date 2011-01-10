From: David Brownell <david-b@pacbell.net>
Subject: Re: rndis gadget: Inconsistent locking
Date: Mon, 10 Jan 2011 04:14:17 -0800 (PST)
Message-ID: <466657.40223.qm@web180306.mail.gq1.yahoo.com>
References: <AANLkTikkkit_L3qHgoyfVUwDYwahbFDJdF8eosH+woAz@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>,
	Neil Jones <neiljay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm25.bullet.mail.sp2.yahoo.com ([98.139.91.95]:43581 "HELO
	nm25.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753802Ab1AJMOU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 07:14:20 -0500
In-Reply-To: <AANLkTikkkit_L3qHgoyfVUwDYwahbFDJdF8eosH+woAz@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> I have just retested Michals patch but I have found another
> lockdep failure.
> 
> It looks like rndis_msg_parser() can call dev_get_stats> too:

Can someone provide a fully working patch then?
Or maybe just revert the one that caused all the
breakage??

Rememeber that this driver was working fine for
years before netdev changes added multiple bugs
because (at least) they didn't update all callers.
