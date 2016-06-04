From: Daniel Schwierzeck <daniel.schwierzeck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v3 1/3] NET: PHY: adds driver for Intel XWAY PHY
Date: Sat, 4 Jun 2016 17:27:38 +0200
Message-ID: <5752F36A.4050007@gmail.com>
References: <1465040728-4904-1-git-send-email-hauke@hauke-m.de>
 <1465040728-4904-2-git-send-email-hauke@hauke-m.de>
 <0DAF21CFE1B20740AE23D6AF6E54843F1E503ECE@IRSMSX101.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "alexander.stein-93q1YBGzJSMe9JSWTWOYM3xStJ4P+DSV@public.gmane.org"
	<alexander.stein-93q1YBGzJSMe9JSWTWOYM3xStJ4P+DSV@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"andrew-g2DYL2Zd6BY@public.gmane.org" <andrew-g2DYL2Zd6BY@public.gmane.org>,
	"john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org" <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>,
	"openwrt-zg6vgJgm1sizQB+pC5nmwQ@public.gmane.org" <openwrt-zg6vgJgm1sizQB+pC5nmwQ@public.gmane.org>,
	"Mehrtens, Hauke" <hauke.mehrtens-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"eckert.florian-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org" <eckert.florian-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Langer, Thomas" <thomas.langer-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0DAF21CFE1B20740AE23D6AF6E54843F1E503ECE-kPTMFJFq+rF9qrmMLTLiibfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Am 04.06.2016 um 16:43 schrieb Langer, Thomas:
> Hello Hauke,
> 
> [...]
>> +
>> +static int xway_gphy_ack_interrupt(struct phy_device *phydev)
>> +{
>> +	int reg;
>> +
>> +	/**
>> +	 * Possible IRQ numbers:
>> +	 * - IM3_IRL18 for GPHY0
>> +	 * - IM3_IRL17 for GPHY1
> 
> These are references to the SoC interrupts.
> 
>> +	 *
>> +	 * Due to a silicon bug IRQ lines are not really independent from
>> +	 * each other. Sometimes the two lines are driven at the same time
>> +	 * if only one GPHY core raises the interrupt.
> 
> So this errata sounds like a SoC errata, not an errata for the PHY.
> 

this comment is a remnant from the first driver version which was mainly
used on a VRX200 SoC. But interrupts are generally working fine so this
comment should be removed.


-- 
- Daniel
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
