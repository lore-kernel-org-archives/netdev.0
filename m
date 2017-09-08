From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: add debugfs interface
Date: Fri, 08 Sep 2017 09:58:56 -0400
Message-ID: <87h8wdb8bj.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com> <20170828191748.19492-2-vivien.didelot@savoirfairelinux.com> <20170907193434.GA11006@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43900 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbdIHOCV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 10:02:21 -0400
In-Reply-To: <20170907193434.GA11006@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

Greg KH <gregkh@linuxfoundation.org> writes:

> I agree you shouldn't be using debugfs for this, but in the future, if
> you do write debugfs code, please take the following review into
> account:

Humm sorry I may not have given enough details. This was really meant
for debug and dev only, because DSA makes it hard to query directly the
hardware (some switch ports are not exposed to userspace as well.)

This is not meant to be used for anything real at all, or even be
compiled-in in a production kernel. That's why I found it appropriate.

So I am still wondering why it doesn't fit here, can you tell me why?

> You should _never_ care about the return value of a debugfs call, and
> you should not need to ever propagate the error upward.  The api was
> written to not need this.
>
> Just call the function, and return, that's it.  If you need to save the
> return value (i.e. it's a dentry), you also don't care, just save it and
> pass it to some other debugfs call, and all will still be fine.  Your
> code should never do anything different if a debugfs call succeeds or
> fails.

Thank for your interesting review! I'll cleanup my out-of-tree patches.


      Vivien
