From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 0/5 v2] mv643xx_eth: device tree bindings
Date: Thu, 11 Apr 2013 19:09:54 +0200
Message-ID: <CABJ1b_T0uvFgfnXbJH6ut-qj621vX5jhedWdWpHUz1wrs84krg@mail.gmail.com>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <20130411165303.GI28693@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 =?ISO-8859-1?Q?Jean=2DFran=E7ois_Moine?= <moinejf@free.fr>,
 Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
 devicetree-discuss@lists.ozlabs.org, Rob Herring <rob.herring@calxeda.com>,
 "David S. Miller" <davem@davemloft.net>,
 Grant Likely <grant.likely@secretlab.ca>, jogo@openwrt.org,
 linux-arm-kernel@lists.infradead.org, Jamie Lentin <jm@lentin.co.uk>,
 Florian Fainelli <florian@openwrt.org>,
 Lennert Buytenhek <buytenh@wantstofly.org>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20130411165303.GI28693@titan.lakedaemon.net>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 11, 2013 at 6:53 PM, Jason Cooper <jason@lakedaemon.net> wrote:
> On Thu, Apr 04, 2013 at 12:27:10PM +0200, Florian Fainelli wrote:
>> This patch serie implements mv643xx_eth device tree bindings. I opted for
>> the reuse of the bindings already defined in
>> Documentation/devicetree/bindings/marvell.txt so that we do not create
>> any confusion.
>>
>
> How is the new version of this looking?  Do you think you'll be able to
> get it up in time for DaveM to take it into v3.10?
>
> With this and Thomas' pci series, we will have Kirkwood fully converted
> to devicetree, can begin removing board files, and finally begin
> migrating everything over to mach-mvebu/.  This will lead to the removal
> of five directories under arch/arm/ (plat-orion, mach-kirkwood,
> mach-orion5x, mach-dove, and mach-mv78xx0).

Jason,

I sent Florian an update of some of his patches earlier, based on
cleanup patches I submitted for mv643xx_eth while testing his patch set.
I think, the patch set will play nicely on ARM but without PPC guys involved
in testing it, I guess it will break something there.

Florian is reusing the DT bindings from PPC and they are compatible, but
there parsing is also done within arch/ppc/sysdev/mv64360-dev.c and
maybe somewhere else. The current DT patches for mv643xx_eth will
reparse some properties again (and may break eth on ppc platforms
using mv643xx_eth).

Sebastian
