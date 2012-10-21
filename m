From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH 3/5] net/at91_ether: move eth addr quirk into csb337 board setup
Date: Sun, 21 Oct 2012 22:30:46 +0200
Message-ID: <CAGhQ9Vw1f18WrQ9N8Pa8hGbJuzh8kYiJLaFxbNkshKH=UosQng@mail.gmail.com>
References: <1350829392-3812-1-git-send-email-manabian@gmail.com>
	<1350829392-3812-4-git-send-email-manabian@gmail.com>
	<20121021183418.GC18964@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, bgat@billgatliff.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:52365 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753634Ab2JUUar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 16:30:47 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so1267742lbo.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 13:30:46 -0700 (PDT)
In-Reply-To: <20121021183418.GC18964@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 21, 2012 at 8:34 PM, Jean-Christophe PLAGNIOL-VILLARD
<plagnioj@jcrosoft.com> wrote:
> On 16:23 Sun 21 Oct     , Joachim Eastwood wrote:
>> Move Ethernet address byte order fix for csb337 into it's board
>> setup.
>>
>> This will allow us to remove the last mach include from at91_ether
>> and also to share the address setup with the macb driver.
> no the current drivers expect mach/board.h, mach/at91rm9200_emac.h, asm/gpio.h
>
> waht you did will not even compile on non at91 platform
>
> Did you even compile it on non at91?

This is the last mach include in the at91_ether driver in net-next.
And, yes, after this patch it complies fine for at least x86_64.

regards
Joachim Eastwood
