From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH 2/5] net/at91_ether: select MACB in Kconfig
Date: Sun, 21 Oct 2012 22:27:41 +0200
Message-ID: <CAGhQ9Vz3LZ4yOeAWBxjmQS4Aw9aFM+PaWaUBYK9K5L+kH8Za4g@mail.gmail.com>
References: <1350829392-3812-1-git-send-email-manabian@gmail.com>
	<1350829392-3812-3-git-send-email-manabian@gmail.com>
	<20121021183122.GB18964@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, bgat@billgatliff.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:48603 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754257Ab2JUU1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 16:27:43 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so1266901lbo.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 13:27:41 -0700 (PDT)
In-Reply-To: <20121021183122.GB18964@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 21, 2012 at 8:31 PM, Jean-Christophe PLAGNIOL-VILLARD
<plagnioj@jcrosoft.com> wrote:
> On 16:23 Sun 21 Oct     , Joachim Eastwood wrote:
>> Now that HAVE_NET_MACB is gone let's just select MACB to
>> satisfy the dependecies in at91_ether.
>>
>> PHYLIB will then by selected by MACB.
>>
>> Signed-off-by: Joachim Eastwood <manabian@gmail.com>
>> ---
>>  drivers/net/ethernet/cadence/Kconfig  | 2 +-
>>  drivers/net/ethernet/cadence/Makefile | 2 +-
>>  2 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
>> index 5d1ea30..f6d0956 100644
>> --- a/drivers/net/ethernet/cadence/Kconfig
>> +++ b/drivers/net/ethernet/cadence/Kconfig
>> @@ -23,7 +23,7 @@ config ARM_AT91_ETHER
>>       tristate "AT91RM9200 Ethernet support"
>>       depends on ARM && ARCH_AT91RM9200
>>       select NET_CORE
>> -     select PHYLIB
>> +     select MACB
> no the ether and macb are two diferrent drivers for 2 IPs from cadence
>
> the ehter does not need the macb

The at91_ether in net-next does.

regards
Joachim Eastwood
