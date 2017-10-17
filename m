From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [iproute2] regression in ss output
Date: Mon, 16 Oct 2017 19:00:36 -0700
Message-ID: <1508205636.31614.81.camel@edumazet-glaptop3.roam.corp.google.com>
References: <AM4PR0901MB125261BF480B49D2BA2DF46BCC480@AM4PR0901MB1252.eurprd09.prod.outlook.com>
         <20171016103320.GP11332@orbyte.nwl.cc>
         <AM4PR0901MB12527C55F04814777A0E6849CC4F0@AM4PR0901MB1252.eurprd09.prod.outlook.com>
         <20171016142807.47825131@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Humberto Alves <hjalves@live.com>, Phil Sutter <phil@nwl.cc>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:47631 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757291AbdJQCAj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 22:00:39 -0400
Received: by mail-pg0-f43.google.com with SMTP id r25so199299pgn.4
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 19:00:39 -0700 (PDT)
In-Reply-To: <20171016142807.47825131@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-16 at 14:28 -0700, Stephen Hemminger wrote:
> On Mon, 16 Oct 2017 20:44:07 +0000
> Humberto Alves <hjalves@live.com> wrote:
> 
> > Yes, just get rid of this 'if statement'.
> > in6addr_any should be represented as '::', not '*'. Otherwise it's 
> > impossible to distinguish IPv4 listening addresses from IPv6. Thank you :)
> 
> But IPv6 accepts IPv4 as well.

Not always (IPV6_V6ONLY socket option)

I agree that this recent change in ss is problematic.

Please give us back a way to distinguish IPV6 and IPv4
