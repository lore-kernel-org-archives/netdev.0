From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: lan9303: Fixed MDIO interface
Date: Wed, 26 Jul 2017 10:30:37 -0400
Message-ID: <87lgnbgtiq.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no> <20170725161553.30147-2-privat@egil-hjelmeland.no> <878tjc49bl.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <87999a6c-4ea8-ba4c-e2db-cdb37c1c8c8a@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, corbet@lwn.net,
        andrew@lunn.ch, f.fainelli@gmail.com, davem@davemloft.net,
        kernel@pengutronix.de, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87999a6c-4ea8-ba4c-e2db-cdb37c1c8c8a@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

>> I'd suggest you to split up this one commit in several *atomic* and easy
>> to review patches and send them separately as on thread named "net: dsa:
>> lan9303: fix MDIO interface" (also note that imperative is prefered for
>> subject lines, see: https://chris.beams.io/posts/git-commit/#imperative)
>
> I can split the first patch.
>
> I can also split the patch series to more digestible series. But
> since most of the patches touches the same file, I assume that each
> series must be completed and applied before starting on a new one.
> So I really want to group the patches into only a few series in order
> to not spend months on the process.

I understand. But believe me, your patches are very likely to land
mainline faster if you send them in small chunks. This might not be true
for every subsystems, but netdev is very responsive. This is even more
true since this series has no-no (such as the sysfs entries) which
guarantees the whole patch series to be rejected.

Sending portions of your local work branch then rebase it against
net-next/master is a usual development process.


Thanks,

        Vivien
