From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 net] net: solve a NAPI race
Date: Mon, 27 Feb 2017 14:44:55 -0800
Message-ID: <20170227144455.174ab1e5@xeon-e3>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
        <1488226711.9415.204.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170227141403.714490f7@xeon-e3>
        <1488234917.9415.217.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:32781 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdB0XJQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 18:09:16 -0500
Received: by mail-pg0-f49.google.com with SMTP id 25so20131088pgy.0
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 15:09:01 -0800 (PST)
In-Reply-To: <1488234917.9415.217.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Feb 2017 14:35:17 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2017-02-27 at 14:14 -0800, Stephen Hemminger wrote:
> 
> > The original design (as Davem mentioned) was that IRQ's must be disabled
> > during device polling. If that was true, then the race above
> > would be impossible.  
> 
> I would love to see an alternative patch.

Turn off busy poll? 
The poll stuff runs risk of breaking more things.
