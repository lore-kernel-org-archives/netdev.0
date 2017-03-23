From: Felix Fietkau <nbd@nbd.name>
Subject: Re: [PATCH net-next v2 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Thu, 23 Mar 2017 15:30:05 +0100
Message-ID: <90daf3f4-cd9f-2c97-2781-feef4c5e2227@nbd.name>
References: <1490088910-19405-1-git-send-email-sean.wang@mediatek.com>
 <1490088910-19405-6-git-send-email-sean.wang@mediatek.com>
 <20170323072233.GA10076@lunn.ch> <1490256416.14184.2.camel@mtkswgap22>
 <c9ffd691-b959-1e19-5bea-6386b816bac2@nbd.name>
 <e55dd89f-e2a6-284e-1905-bd8dc92a042d@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org,
        Landen.Chao@mediatek.com, f.fainelli@gmail.com, keyhaede@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, robh+dt@kernel.org,
        linux-mediatek@lists.infradead.org, objelf@gmail.com,
        matthias.bgg@gmail.com, davem@davemloft.net
To: John Crispin <john@phrozen.org>,
        Sean Wang <sean.wang@mediatek.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e55dd89f-e2a6-284e-1905-bd8dc92a042d@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-03-23 15:25, John Crispin wrote:
> 
> 
> On 23/03/17 15:09, Felix Fietkau wrote:
>> On 2017-03-23 09:06, Sean Wang wrote:
>>> Hi Andrew,
>>>
>>> The purpose for the regmap table registered is to
>>>
>>> provide a way which helps us to look up a specific
>>>
>>> register on the switch through regmap-debugfs.
>>>
>>>
>>> And not all ranges of register is defined
>>>
>>> so I only include the meaningful ones in a sparse way
>>>
>>> for the table.
>> I think in that case it might be nice to make regmap support optional in
>> order to avoid pulling in bloat on platforms that don't need it.
>>
>> - Felix
>>
> The 2 relevant platforms are mips/ralink and arm/mediatek. both require 
> regmap for the eth_sysctl syscon if they want to utilize the mtk_soc_eth 
> driver which is a prereq for mt7530. so regmap cannot be optional here.
Makes sense, thanks.

- Felix
