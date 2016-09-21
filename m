From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 1/3] net: ethernet: mediatek: add extension of
 phy-mode for TRGMII
Date: Wed, 21 Sep 2016 15:33:09 +0800
Message-ID: <1474443189-8836-1-git-send-email-sean.wang@mediatek.com>
References: <064d43fb-2942-efd2-6dc7-09f47a256691@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <064d43fb-2942-efd2-6dc7-09f47a256691-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Date: Tue, 20 Sep 2016 14:23:24 -0700, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>On 09/20/2016 12:59 AM, sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org wrote:
>> From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
>> 
>> adds PHY-mode "trgmii" as an extension for the operation
>> mode of the PHY interface, TRGMII can be compatible with
>> RGMII, so the extended mode doesn't really have effects on
>> the target MAC and PHY, is used as the indication if the
>> current MAC is connected to an internal switch or external
>> PHY respectively by the given configuration on the board and
>> then to perform the corresponding setup on TRGMII hardware
>> module.
>
>Based on my googling, it seems like Turbo RGMII is a Mediatek-specific
>thing for now, but this could become standard and used by other vendors
>at some point, so I would be inclined to just extend the phy-mode
>property to support trgmii as another interface type.
>
>If you do so, do you also mind proposing an update to the Device Tree
>specification:
>
>https://www.devicetree.org/specifications/
>
>Thanks!

I am willing to do the these thing

1)
in the next version, I will extend rgmii mode as
another interface type as PHY_INTERFACE_MODE_TRGMII
defined in linux/phy.h instead of extension only inside
the current driver. This change also helps to save some code.

2)
I send another separate patch for updating the Device Tree
specification about TRGMII adding description

are these all okay for you?
