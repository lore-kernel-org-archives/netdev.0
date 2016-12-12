From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store multicast entries
Date: Mon, 12 Dec 2016 12:11:07 -0500
Message-ID: <87twa9oyxg.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com> <87r35db35m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com> <48ff1136-dd8f-7704-a512-c23b27989bf8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>, andrew@lunn.ch,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Volodymyr Bendiuga <valdr.linuxnext@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:42444 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932915AbcLLRLO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 12:11:14 -0500
In-Reply-To: <48ff1136-dd8f-7704-a512-c23b27989bf8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Florian Fainelli <f.fainelli@gmail.com> writes:

> Seeing such a change makes me wonder if we should not try to push some
> of this hashtable abstraction (provided that we agree we want it) at a
> higher layer, like net/dsa/slave.c?

That is the major reason why I am reluctant to cache stuffs in drivers.

In most cases, we want the DSA drivers to be "stupid", as much stateless
as possible, simply implementing the supported DSA switch operations.

The DSA core then handles the generic logic of how switch fabrics should
behave, and thus all DSA drivers are consistent and benefit from this.

Thanks,

        Vivien
