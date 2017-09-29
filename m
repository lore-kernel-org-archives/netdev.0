From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/8] net: dsa: change dsa_ptr for a dsa_port
Date: Fri, 29 Sep 2017 15:34:40 -0400
Message-ID: <877ewhqoxb.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170929183635.8122-1-vivien.didelot@savoirfairelinux.com> <03cef84e-546d-d8c2-85fb-afc697ced2cb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <03cef84e-546d-d8c2-85fb-afc697ced2cb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 09/29/2017 11:36 AM, Vivien Didelot wrote:
>> With DSA, a master net_device is physically wired to a dedicated CPU
>> switch port. For interaction with the DSA layer, the struct net_device
>> contains a dsa_ptr, which currently points to a dsa_switch_tree object.
>> 
>> This is only valid for a switch fabric with a single CPU port. In order
>> to support switch fabrics with multiple CPU ports, we first need to
>> change the type of dsa_ptr to what it really is: a dsa_port object.
>> 
>> This is what this patchset does. The first 4 patches cleans up portions
>> of DSA core to make the next patches more readable. These next patches
>> prepare the xmit and receive hot paths and finally change dsa_ptr.
>
> This looks nice and clean, as mentioned in patch 5, there may be room
> for organizing the structure a bit more efficiently such that everything
> still fits within the first cacheline .

Thanks for this very constructive comment! I'll look into this.


Respinning in a few.

           Vivien
