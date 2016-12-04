From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v1 net-next 1/5] net: dsa: mv88e6xxx: Reserved Management frames to CPU
Date: Sun, 04 Dec 2016 17:12:05 -0500
Message-ID: <87oa0r9wei.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1480736720-12608-1-git-send-email-andrew@lunn.ch> <1480736720-12608-2-git-send-email-andrew@lunn.ch> <87y3zvcvhm.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me> <20161204202234.GA20743@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41142 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbcLDWMQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 17:12:16 -0500
In-Reply-To: <20161204202234.GA20743@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> The mv88e6xxx_ops actually implements the *features*. They can be
>> prefixed for clarity (e.g. .ppu_*, port_*, .atu_*, etc.). They don't
>> describe the register layout.
>> 
>> But we can discuss two ways of seeing this structure implementation:
>
> or
>
> 3) We have a prefix for us humans to help us find the code. Now we
> have ops, i cannot simply do M-. and emacs will take me to the
> implementation. I have to search for it a bit. Having the hint g1_
> tells me to go look in global1.c. Having the hint g2_ tells me to go
> look in global2.c. Having the port_ tells me to go look in port.c.
> Having no prefix tells me the code is scattered around and grep is my
> friend.

Just to be clear:

I totally agree for an implementation (e.g. mv88e6095_g1_set_cpu_port),
that's why I've been doing it since I started splitting the code around
in device-specific files. But I disagree for an mv88e6xxx_ops member.

You can have several implementations in the same file (e.g. global1.c),
so again the only value is the function name, not the struct member.


Thanks,

     Vivien
