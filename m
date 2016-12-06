From: Stefan Eichenberger <eichest@gmail.com>
Subject: Re: [PATCH v2 net-next v2 4/4] net: dsa: mv88e6xxx: add PPU operations
Date: Tue, 6 Dec 2016 13:27:16 +0100
Message-ID: <CAD4aGmR0B9PPs=4sBMQKCn=yKB1sJC62+bJdPtPe7HeL6TZ4_w@mail.gmail.com>
References: <20161205162703.22567-1-vivien.didelot@savoirfairelinux.com>
 <20161205162703.22567-5-vivien.didelot@savoirfairelinux.com>
 <20161205210439.GA6038@eichest-notebook> <874m2ic95g.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Richard Cochran <richardcochran@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <874m2ic95g.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5 December 2016 at 23:18, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> Stefan Eichenberger <eichest@gmail.com> writes:
>
>> Hi Vivien,
>>
>> On Mon, Dec 05, 2016 at 11:27:03AM -0500, Vivien Didelot wrote:
>>> @@ -3266,6 +3220,8 @@ static const struct mv88e6xxx_ops mv88e6097_ops = {
>>>      .g1_set_cpu_port = mv88e6095_g1_set_cpu_port,
>>>      .g1_set_egress_port = mv88e6095_g1_set_egress_port,
>>>      .mgmt_rsvd2cpu = mv88e6095_g2_mgmt_rsvd2cpu,
>>> +    .ppu_enable = mv88e6185_g1_ppu_enable,
>>> +    .ppu_disable = mv88e6185_g1_ppu_disable,
>>>      .reset = mv88e6185_g1_reset,
>>>  };
>>
>> The mv88e6097 should use the indirect access to the phys, bit 14 in g1
>> control is marked as reserved. They write in the datasheet that
>> disabling the PPU is still supported but indirect access via g2 should
>> be used because disabling the PPU  is no longer recommended.
>
> Ho ok thanks, I respin a v3 right away with this removed and with
> mv88e6352_g1_reset instead.

Perfect thank you, now it's fine.

Regards,
Stefan
