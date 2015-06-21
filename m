From: Nicolai Stange <nicstange@gmail.com>
Subject: Re: [PATCH] isdn: disable HiSax NetJet driver on microblaze arch
Date: Sun, 21 Jun 2015 19:59:11 +0200
Message-ID: <87y4jdc58w.fsf@gmail.com>
References: <87pp4vw3ep.fsf@gmail.com>
	<20150621.095400.890337700038231482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nicstange@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, isdn@linux-pingi.de, jdelvare@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:34351 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbbFUR7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 13:59:15 -0400
In-Reply-To: <20150621.095400.890337700038231482.davem@davemloft.net> (David
	Miller's message of "Sun, 21 Jun 2015 09:54:00 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:
>> Note that endianess on microblaze is not determined through Kconfig,
>> but by means of a compiler provided CPP macro, namely __MICROBLAZEEL__.
>> However, gcc defaults to big endianess on that platform.
> Applied, but we're long overdue for an across-the-board-available
> endianness Kconfig option that can flat out be used in these situations.
> The current way this is handled is at best, a mess.

Thanks!

Regarding the general Kconfig endianess symbol, I will do another patch
based on the information of
  git grep '_endian\.h' -- arch/
and supply every arch with either of CONFIG_CPU_{LITTLE,BIG}_ENDIAN if
lacking.
