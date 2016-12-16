From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store
 multicast entries
Date: Fri, 16 Dec 2016 12:01:15 +0100
Message-ID: <20161216110115.GC20359@lunn.ch>
References: <20161213150948.GD20323@lunn.ch>
 <CABHmqqB-6-L124hrAjNxd4kO3zYp9R=RM1X6PXyuQW6Hapiv4g@mail.gmail.com>
 <20161214104614.GD27370@lunn.ch>
 <CABHmqqDpiN2kwkTgrM8Qu8EEx3Sjk2yVBy8QQAJppGfJ6-MV5Q@mail.gmail.com>
 <87eg19hzw1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <be3b69b7-b6a3-a939-cf77-c62e5a1fe719@gmail.com>
 <87bmwdcc96.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CABHmqqCOYMPA-Py7Uu4gsQ=s8CrQd-tT4-Db+j8eJH9=2s4L2g@mail.gmail.com>
 <20161216100802.GA20359@lunn.ch>
 <CABHmqqAQddcQZqVBi7gTjR40cHx6+aQebmsY3BwJgeEbLsX5Yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Volodymyr Bendiuga <valdr.linuxnext@gmail.com>,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>,
        John Crispin <john@phrozen.org>
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56733 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759512AbcLPLkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 06:40:16 -0500
Content-Disposition: inline
In-Reply-To: <CABHmqqAQddcQZqVBi7gTjR40cHx6+aQebmsY3BwJgeEbLsX5Yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 16, 2016 at 11:26:01AM +0100, Volodymyr Bendiuga wrote:
> Hi Andrew,
> 
> I don't have any script right now, the code I have is a part of
> the OS, but I could write simple C program which represents
> what we are doing with mc entries and send it to you for profiling.

It would be nice to have a benchmark test we can use to test out
ideas.

Please try to make the code flexible. The slave interface names on my
boards are probably not the same as on your. Also, the number of ports
may differ.

    Thanks
	Andrew
