From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] tulip: de2104x, fix init. sections
Date: Tue, 1 Mar 2005 23:02:16 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0503012253530.25732@ppc970.osdl.org>
References: <20050301214438.4653810e.randy.dunlap@verizon.net>
 <422558B2.6020105@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Randy.Dunlap" <randy.dunlap@verizon.net>, netdev@oss.sgi.com,
        akpm <akpm@osdl.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <422558B2.6020105@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 2 Mar 2005, Jeff Garzik wrote:
> 
> Nobody ever hotplugs a de2104x.

Are you sure? I'm pretty certain some of the Cardbus cards are based on
that chipset. In fact, I'm pretty sure that's exactly that I used to have
(and actually used when I did the "CardBus as a real PCI bridge" stuff).

CardBus tulip network cards may be less interesting these days, but I'd be
surprised if they are all gone. The tulip chip used to be the most common
one.

(And don't be fooled by the Xircom config stuff - those have a special
driver partly because Xircom did something wrong, and probably partly
because the old PCMCIA layer just was too damn confused, and thought that
CardBus devices needed something else than a PCI driver. Most tulip
cardbus cards used just the bog-standard tulip driver after my Cardbus
rewrite, I do believe).

		Linus
