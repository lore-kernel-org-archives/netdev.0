From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [RFC PATCH net-next 0/6] net: dsa: mv88e6060: cleanup and fix
 setup
Date: Tue, 3 Nov 2015 17:27:26 +0100
Message-ID: <5638E06E.8010405@baylibre.com>
References: <5637417D.6060503@baylibre.com>
 <20151102154121.GB3036@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151102154121.GB3036@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/02/2015 04:41 PM, Vivien Didelot wrote:
> Hi Neil,
> 
> Nice cleanup. I'll just be a bit picky here, so you may not consider my
> comment for this patchset, but maybe for the future ones. Unless I'm
> mistaken, there is no reason to group all these patches together.
> 
> The first 4 patches are independent fixes, and thus could have been sent
> separately to netdev -net.
> 
> Then the last 2 ones could have been squashed together, because I don't
> see a real value to seperate them since you duplicate some defines, e.g.
> REG_PORT. And this patch would be a candidate for netdev -net-next.
> 
> Thanks,
> -v
> 
Hi Vivien,

I understand your point of view, and it really makes sense.

But the first patch has a dependency on the DSA cleanup patchset, so
if I follow your point, I should submit 3 patchsets with a single
patchset for the poll_link complete removal. But the two other
patchsets will have a strong dependency on the poll_link removal...

This question is on which version of mv88e6060 and dsa should I base
the cleanup patchset ? before of after the poll_link removal ?

For the fixes, they are not critical at all, net-next would be enough.

Any advice is welcome at this point....

Thanks !

Neil
