From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH 3/5] net/at91_ether: move eth addr quirk into csb337 board setup
Date: Sun, 21 Oct 2012 22:39:48 +0200
Message-ID: <CAGhQ9VzHAy3vy5-rz5E1UeRx8nrwYtkjWFEBJBt+uL=QL1FUUw@mail.gmail.com>
References: <1350829392-3812-1-git-send-email-manabian@gmail.com>
	<1350829392-3812-4-git-send-email-manabian@gmail.com>
	<20121021182551.GH12801@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, bgat@billgatliff.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:43418 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754257Ab2JUUjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 16:39:49 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so1269863lbo.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 13:39:48 -0700 (PDT)
In-Reply-To: <20121021182551.GH12801@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 21, 2012 at 8:25 PM, Jean-Christophe PLAGNIOL-VILLARD
<plagnioj@jcrosoft.com> wrote:
> On 16:23 Sun 21 Oct     , Joachim Eastwood wrote:
>> Move Ethernet address byte order fix for csb337 into it's board
>> setup.
>>
>> This will allow us to remove the last mach include from at91_ether
>> and also to share the address setup with the macb driver.
> no the at91rm9200 move to DT this is not compatible with it
>
> you need to pass ths in info via platform_data
>
> and do not touch driver code related stuff in boards

I know the board code is a bit nasty.
If it's unacceptable I'll cook up a flag and pass it by platform_data,
something like "reverse_eth_addr". Still it will only ever be used on
the csb337 board.

regards
Joachim Eastwood
