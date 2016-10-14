From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH trivial] net: add bbr to config DEFAULT_TCP_CONG
Date: Fri, 14 Oct 2016 11:17:27 -0400 (EDT)
Message-ID: <20161014.111727.1347759995128120612.davem@davemloft.net>
References: <20161014073333.GA10006@x4>
        <1476431026.5650.38.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161014080716.GA306@x4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ncardwell@google.com,
        netdev@vger.kernel.org
To: markus@trippelsdorf.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752098AbcJNPR2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 11:17:28 -0400
In-Reply-To: <20161014080716.GA306@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Trippelsdorf <markus@trippelsdorf.de>
Date: Fri, 14 Oct 2016 10:07:16 +0200

> On 2016.10.14 at 09:43 +0200, Eric Dumazet wrote:
>> On Fri, 2016-10-14 at 09:33 +0200, Markus Trippelsdorf wrote:
>> > While playing with BBR I noticed that it was missing in the list of
>> > possible config DEFAULT_TCP_CONG choices. Fixed thusly.
>> > 
>> > Signed-off-by: Markus Trippelsdorf <markus@trippelsdorf.de>
>> > 
>> > diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>> > index 300b06888fdf..b54b3ca939db 100644
>> > --- a/net/ipv4/Kconfig
>> > +++ b/net/ipv4/Kconfig
>> > @@ -715,6 +715,7 @@ config DEFAULT_TCP_CONG
>> >  	default "reno" if DEFAULT_RENO
>> >  	default "dctcp" if DEFAULT_DCTCP
>> >  	default "cdg" if DEFAULT_CDG
>> > +	default "bbr" if DEFAULT_BBR
>> >  	default "cubic"
>> 
>> Not sure if we want this at this moment.
>> 
>> BBR needs FQ packet scheduler, and this is not exactly trivial to
>> achieve.
> 
> For a start, it could be automatically selected:

Right but FQ has to be properly enabled and configured as well.
