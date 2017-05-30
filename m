From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 4/7] net: dsa: free orig skb on rcv if reallocated
Date: Tue, 30 May 2017 11:41:51 -0400
Message-ID: <8737bm4aio.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com> <20170530142131.23568-5-vivien.didelot@savoirfairelinux.com> <20170530152505.GG22758@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50676 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdE3Pnz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 11:43:55 -0400
In-Reply-To: <20170530152505.GG22758@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> On Tue, May 30, 2017 at 10:21:28AM -0400, Vivien Didelot wrote:
>> If the receive function of a tagger reallocated the SKB, the original
>> SKB is currently not freed. Fix this and free it on both copy or error.
>
> I don't see any of the receive functions reallocate the skb. It might
> be better to just simplify the code to take away the option to return
> a different skb.

I think it was written such way to be symmetrical with the xmit
implementation, where the trailer tagger does reallocate the skb.

I would say that keeping the symmetry is simpler from the point of view
of the tagging implementations, but I don't have strong opinion here.

Thanks,

        Vivien
