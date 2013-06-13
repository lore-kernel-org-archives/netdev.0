From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH net-next] bcm63xx_enet: add support Broadcom BCM6345
 Ethernet
Date: Thu, 13 Jun 2013 16:24:07 +0200
Message-ID: <1371133447.3032.37.camel@sakura.staff.proxad.net>
References: <1371066785-17168-1-git-send-email-florian@openwrt.org>
         <20130613.014450.1434692343011842828.davem@davemloft.net>
         <CAGVrzcYE4VDWtL_Uj1DrkZ6GqX6ghqPAXPpyLptc6PGwReixSQ@mail.gmail.com>
         <20130613.022524.568792627006552244.davem@davemloft.net>
         <CAGVrzcaqbdLPcuL0m56aBLuG9ruaQ1p4JfTWZV9DJ4zSrNcXtg@mail.gmail.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        ralf@linux-mips.org, John Crispin <blogic@openwrt.org>,
        Linux-MIPS <linux-mips@linux-mips.org>, jogo@openwrt.org,
        Kevin Cernekee <cernekee@gmail.com>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <CAGVrzcaqbdLPcuL0m56aBLuG9ruaQ1p4JfTWZV9DJ4zSrNcXtg@mail.gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org


On Thu, 2013-06-13 at 10:49 +0100, Florian Fainelli wrote:

> We are in the slow process to switch to Device Tree to precisely
> eliminate all of this (although not everyone agrees yet on the
> details). Hopefully you should not see such things in the future.

I don't see how DT help here (hint: it never does)

if the driver knows at compile time how registers are shuffled, it can
remove the indirection

if you use runtime cpu detection or DT, it cannot

in fact, this patch already adds another layer of indirection with that
"dma_chan_width" thing that the compiler has no way to optimize out,
defeating the purpose of single SOC optimization.

so we might as well force multi SOC support

-- 
Maxime
