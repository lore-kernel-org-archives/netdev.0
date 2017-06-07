From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/5] net: dsa: check VLAN capability of every switch
Date: Wed, 07 Jun 2017 16:03:31 -0400
Message-ID: <87bmpza7l8.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170606205631.22880-1-vivien.didelot@savoirfairelinux.com> <20170606205631.22880-3-vivien.didelot@savoirfairelinux.com> <8d6edbe3-a80b-6cc7-b7ec-d8f1578dea27@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8d6edbe3-a80b-6cc7-b7ec-d8f1578dea27@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 06/06/2017 01:56 PM, Vivien Didelot wrote:
>> Now that the VLAN object is propagated to every switch chip of the
>> switch fabric, we can easily ensure that they all support the required
>> VLAN operations before modifying an entry on a single switch.
>> 
>> To achieve that, remove the condition skipping other target switches,
>> and add a bitmap of VLAN members, eventually containing the target port,
>> if we are programming the switch target.
>
> You could add in the commit message that with this commit, there is not
> actually a functional change yet because we have one (and only one) bit
> set in the members bitmap.

Hum there is a small functional change though: if one interconnected
switch of the fabric does not support the VLAN operations, -EOPNOTSUPP
is returned (even though the target switch is VLAN capable.)

Thanks,

        Vivien
