From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store multicast entries
Date: Thu, 15 Dec 2016 12:50:45 -0500
Message-ID: <87bmwdcc96.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com> <87r35db35m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com> <48ff1136-dd8f-7704-a512-c23b27989bf8@gmail.com> <20161212190915.GA8885@lunn.ch> <CAMr9LbqyvrRYe_m34Ufzxkf2Vef3LbMQiuoiwVX0mK=hW6euyA@mail.gmail.com> <20161213150948.GD20323@lunn.ch> <CABHmqqB-6-L124hrAjNxd4kO3zYp9R=RM1X6PXyuQW6Hapiv4g@mail.gmail.com> <20161214104614.GD27370@lunn.ch> <CABHmqqDpiN2kwkTgrM8Qu8EEx3Sjk2yVBy8QQAJppGfJ6-MV5Q@mail.gmail.com> <87eg19hzw1.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <be3b69b7-b6a3-a939-cf77-c62e5a1fe719@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Volodymyr Bendiuga <valdr.linuxnext@gmail.com>,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>,
        John Crispin <john@phrozen.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45088 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754183AbcLORu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 12:50:58 -0500
In-Reply-To: <be3b69b7-b6a3-a939-cf77-c62e5a1fe719@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

>> In all cases *if caching is really needed*, I think it won't hurt to do
>> it in DSA core even if a switch support FDB dump operations on a
>> per-port basis, as Andrew mentioned.
>
> Agreed, and there does not appear to be any need to new dsa_switch_ops
> operations to be introduced?

Nope.
