From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: igb: question regarding auto-negotiation
Date: Fri, 29 Jul 2016 21:35:21 -0700
Message-ID: <CAKgT0UfAawN49bc5kWjnynHhA4rBddQOJ320SdaK57yDCNFb_A@mail.gmail.com>
References: <579BE8C3.806@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Dominic Curran <dominic.curran@citrix.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:38219 "EHLO
	mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbcG3EfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 00:35:23 -0400
Received: by mail-it0-f50.google.com with SMTP id j124so126557504ith.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 21:35:23 -0700 (PDT)
In-Reply-To: <579BE8C3.806@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 29, 2016 at 4:37 PM, Dominic Curran
<dominic.curran@citrix.com> wrote:
> Hi
>
> This question refers to igb codebase.
> I have a question regarding the setting of hw->mac.autoneg.
>
> Is it correct to say for igb driver:
>    "if speed=1000 and duplex=FULL and media_type=COPPER  then  only
> auto-negotiate enable is supported"
>
> i.e.
>    with these settings (speed/duplex/media_type) then auto-negotiate can
> _not_ be disabled.  Correct ?
>
> I say this for two reasons:
> 1) The code in igb_set_spd_dplx() seems to indicate it:
>
>        case SPEED_1000 + DUPLEX_FULL:
>                 mac->autoneg = 1;
>                 adapter->hw.phy.autoneg_advertised = ADVERTISE_1000_FULL;
>                 break;
>
> 2) Instrumenting the driver, I always see the autoneg code in
> e1000_check_for_copper_link_generic()  get called after an igb_reset().
>
>
> Have i understood correctly ?
>
> thanks in advance
> dom

If you are using copper then you are likely referring to 1000Base-T
correct?  If so then autonegotation is a requirement.

Here is the wikipedia URL that refers to this:
https://en.wikipedia.org/wiki/Gigabit_Ethernet#1000BASE-T

Hope this helps to clear it up.

Thanks.

- Alex
