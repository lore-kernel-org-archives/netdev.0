From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 2/6] net: dsa: mv88e6xxx: move ATU code in its own file
Date: Fri, 17 Feb 2017 16:54:50 -0500
Message-ID: <87fujcmqj9.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com> <20170217150531.2181-3-vivien.didelot@savoirfairelinux.com> <20170217213518.GH6096@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170217213518.GH6096@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> This seems to be more than renaming a few functions. There looks to be
> real changes here. I think these changes should be split out into a
> separate patch with an explanation what is being changed. Keep this
> patch for plain renames.
>
> It would also be easier to review if the patch just moved the code, no
> changes. Then have patches which clean up the API. It is hard to see
> what is move and what is cleanup. Plain move needs little review,
> cleanup needs more review. With the current patch, it is hard to see
> which is which.

I understand your concerns about that. I've started that way (just
moving code) but this ended up messier because of the naming convention
which would required renaming and more diffstats. I found it actually
easier to review the new code at once by reading all the addition block.

Note that we are very close from 4.10, so unless there is a major issue
in the patchset, I'd prefer not to respin new versions. I'd gladly send
cosmetics fixup later though. I'm waiting for this patchset to land in
net-next to send the second one ready for cross-chip bridging in DSA.

Thanks,

        Vivien
