From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Minimum MTU Mess
Date: Mon, 12 Sep 2016 04:41:40 +0200
Message-ID: <20160912024140.GA6264@lunn.ch>
References: <20160902170742.GA17677@redhat.com>
 <20160906.165529.496766310703537877.davem@davemloft.net>
 <20160907195356.GX33916@redhat.com>
 <20160907203112.GA26445@lunn.ch>
 <20160907234306.GY33916@redhat.com>
 <20160908012413.GA12745@lunn.ch>
 <20160909180555.GE20632@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41166 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756080AbcILClp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 11 Sep 2016 22:41:45 -0400
Content-Disposition: inline
In-Reply-To: <20160909180555.GE20632@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Actually breaking this up into easily digestable/mergeable chunks is going
> to be kind of entertaining... Suggestions welcomed on that. First up is
> obviously the core change, which touches just net/ethernet/eth.c,
> net/core/dev.c, include/linux/netdevice.h and
> include/uapi/linux/if_ether.h, and should let existing code continue to
> Just Work(tm), though devices using ether_setup() that had no MTU range
> checking (or one or the other missing) will wind up with new bounds.

Hi Jarod

Did you find any drivers which support jumbo packets, but don't have
checks? These drivers, if there are any, need handling first, before
this core change is made. Otherwise you introduce regressions.

     Andrew
