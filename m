From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [PATCH net] bnx2x: Restore a call to config_init
Date: Sat, 7 Sep 2013 13:35:26 +0300
Message-ID: <CAM8tLiNj-s0RKUeKePDURK7W7HZF=8Zz7D073qcqCLmy75CevQ@mail.gmail.com>
References: <1378461302.15758.2.camel@lb-tlvb-eilong.il.broadcom.com>
	<20130906.144733.708978789363351557.davem@davemloft.net>
	<1378507183.31445.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, davej@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:51762 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab3IGKf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 06:35:27 -0400
Received: by mail-vc0-f174.google.com with SMTP id gd11so2834740vcb.33
        for <netdev@vger.kernel.org>; Sat, 07 Sep 2013 03:35:27 -0700 (PDT)
In-Reply-To: <1378507183.31445.53.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 7, 2013 at 1:39 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-09-06 at 14:47 -0400, David Miller wrote:
>> From: "Eilon Greenstein" <eilong@broadcom.com>
>> Date: Fri, 6 Sep 2013 12:55:02 +0300
>>
>> > Commit c0a77ec74f295013d7ba3204dd3ed25fccf83cb4 'bnx2x: Add missing braces in
>> > bnx2x:bnx2x_link_initialize' identified indentation problem, but resolved it
>> > by adding braces instead of fixing the indentation. The braces now prevents a
>> > config_init call in some cases, though it should be called regardless of that
>> > condition. This patch removes the braces and fix the confusing indentation
>> > that caused this mess.
>> >
>> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>>
>> Applied.
>
> Oh well, latest net tree broke bnx2x again.
>
> No idea why.
>
> [   61.203313] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [   74.021238] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [   76.109176] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [   78.198178] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [   80.286960] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [   93.031584] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [   95.069939] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [   97.133493] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [   99.195912] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [  112.026026] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [  114.087991] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [  116.148976] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[1]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)
> [  118.237310] bnx2x: [bnx2x_clean_tx_queue:1259(eth0)]timeout waiting for queue[2]: txdata->tx_pkt_prod(1) != txdata->tx_pkt_cons(0)

Unable to reproduce ,,,
Which HW you have - i will try to get similar...
Thanks
