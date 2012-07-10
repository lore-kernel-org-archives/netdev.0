From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 4 0/4] Add ability to set defaultless network device MAC
 addresses to deterministic computed locally administered values
Date: Tue, 10 Jul 2012 09:08:49 -0400
Message-ID: <1341925729.14828.17.camel@gandalf.stny.rr.com>
References: <20120705024259.26317.16000.stgit@build.warmcat.com>
	 <201207101437.54877.florian@openwrt.org> <4FFC2712.9020208@warmcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <florian@openwrt.org>,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	s-jan@ti.com, arnd@arndb.de, patches@linaro.org, tony@atomide.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "\"Andy Green" =?UTF-8?Q?=28=E6=9E=97=E5=AE=89=E5=BB=B8=29=22?=
	<andy@warmcat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FFC2712.9020208@warmcat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-07-10 at 20:58 +0800, "Andy Green (=E6=9E=97=E5=AE=89=E5=BB=
=B8)" wrote:
> On 10/07/12 20:37, the mail apparently from Florian Fainelli included=
:
>=20

> Why should Ubuntu, Fedora etc stink up their OSes with Panda-specific=
=20
> workarounds?  And Panda is not the only device with this issue.

Actually I think you just answered your own question ;-)

Anyway, I don't think an initrd solution is the best. Yeah, it's fine
for a work around, but then I need to go and screw with the initrd if i=
t
doesn't have support for the board. If the network card already has a
MAC address, why should the kernel give it another *random* one?

This isn't a complex patch set, where the complexity should be put into
userspace. And it makes it very convenient for people that just want th=
e
board to boot so they can test it. I'm not developing any SoC or BSP,
I'm just using it to make sure my kernel changes can also be implemente=
d
for ARM.

-- Steve
