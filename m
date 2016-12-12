From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store
 multicast entries
Date: Mon, 12 Dec 2016 17:07:28 +0100
Message-ID: <20161212160728.GA3257@lunn.ch>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
 <87r35db35m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
To: Volodymyr Bendiuga <valdr.linuxnext@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52566 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752136AbcLLQHb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 11:07:31 -0500
Content-Disposition: inline
In-Reply-To: <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 04:22:13PM +0100, Volodymyr Bendiuga wrote:
> Hi,
> 
> I apologise for incorrectly formatted patch, I will fix and resend it.

Please don't resend with just the white space fixed. The memory model
is very important, using the fdb_prepare() call to allocate memory,
etc.

   Andrew
