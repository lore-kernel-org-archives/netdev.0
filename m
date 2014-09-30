From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v5 2/3] net: Add Keystone NetCP ethernet driver
Date: Tue, 30 Sep 2014 15:28:23 +0200
Message-ID: <CAMuHMdXe2H4qfX4X4GDzJSgoWzu-BrvRL6KoZagepY1GYEA4Ag@mail.gmail.com>
References: <1411667317-1163-1-git-send-email-santosh.shilimkar@ti.com>
	<1411667317-1163-3-git-send-email-santosh.shilimkar@ti.com>
	<20140929.155200.2231132602322345812.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6D174A1012@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"santosh.shilimkar@ti.com" <santosh.shilimkar@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"sandeep_n@ti.com" <sandeep_n@ti.com>,
	"joe@perches.com" <joe@perches.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174A1012@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 30, 2014 at 3:09 PM, David Laight <David.Laight@aculab.com> wrote:
>> > +static inline int gbe_phy_link_status(struct gbe_slave *slave)
>> > +{
>> > +   if (!slave->phy)
>> > +           return 1;
>> > +
>> > +   if (slave->phy->link)
>> > +           return 1;
>> > +
>> > +   return 0;
>> > +}
>>
>> Please use 'bool' as the return type and return 'true' or 'false'.
>
> That function body could also be just:
>         return !slave->phy && slave->phy->link;
> which might be more readable if directly coded.

return !slave->phy || slave->phy->link;

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
