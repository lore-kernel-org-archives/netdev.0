From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH net-next v2 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Thu, 23 Mar 2017 15:25:39 +0100
Message-ID: <e55dd89f-e2a6-284e-1905-bd8dc92a042d@phrozen.org>
References: <1490088910-19405-1-git-send-email-sean.wang@mediatek.com>
 <1490088910-19405-6-git-send-email-sean.wang@mediatek.com>
 <20170323072233.GA10076@lunn.ch> <1490256416.14184.2.camel@mtkswgap22>
 <c9ffd691-b959-1e19-5bea-6386b816bac2@nbd.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mark.rutland-5wv7dgnIgG8@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Felix Fietkau <nbd-Vt+b4OUoWG0@public.gmane.org>, Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <c9ffd691-b959-1e19-5bea-6386b816bac2-Vt+b4OUoWG0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 23/03/17 15:09, Felix Fietkau wrote:
> On 2017-03-23 09:06, Sean Wang wrote:
>> Hi Andrew,
>>
>> The purpose for the regmap table registered is to
>>
>> provide a way which helps us to look up a specific
>>
>> register on the switch through regmap-debugfs.
>>
>>
>> And not all ranges of register is defined
>>
>> so I only include the meaningful ones in a sparse way
>>
>> for the table.
> I think in that case it might be nice to make regmap support optional in
> order to avoid pulling in bloat on platforms that don't need it.
>
> - Felix
>
The 2 relevant platforms are mips/ralink and arm/mediatek. both require 
regmap for the eth_sysctl syscon if they want to utilize the mtk_soc_eth 
driver which is a prereq for mt7530. so regmap cannot be optional here.

     John


>
> _______________________________________________
> Linux-mediatek mailing list
> Linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-mediatek

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
