From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] NET: AX88796: Tighten up Kconfig dependencies
Date: Mon, 27 Jun 2011 13:17:54 +0400
Message-ID: <4E084AC2.5060908@mvista.com>
References: <20110625180050.GA9620@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, Russell King <linux@arm.linux.org.uk>,
	Jeff Garzik <jeff@garzik.org>, linux-sh@vger.kernel.org,
	netdev@vger.kernel.org, Magnus Damm <magnus.damm@gmail.com>,
	linux-kernel@vger.kernel.org, Paul Mundt <lethal@linux-sh.org>,
	Ben Dooks <ben-linux@fluff.org>, Eric Miao <eric.y.miao@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20110625180050.GA9620@linux-mips.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello.

On 25-06-2011 22:00, Ralf Baechle wrote:

> In def47c5095d53814512bb0c62ec02dfdec769db1 the AX88796 driver got

    Please also specify the summary of that commit.

> restricted to just be build for ARM and MIPS on the sole merrit that it

    Merit?

> was written for some ARM sytems and the driver had the missfortune to

    Misfortune?

> just build on MIPS, so MIPS was throw into the dependency for a good
> measure.  Later 8687991a734a67f1638782c968f46fff0f94bb1f added SH but

    Summary here too, please.

> only one in-tree SH system actually has an AX88796.

> Tighten up dependencies by using an auxilliary config sysmbol
> HAS_NET_AX88796 which is selected only by the platforms that actually
> have or may have an AX88796.  This also means the driver won't be built
> anymore for any MIPS platform.

> Signed-off-by: Ralf Baechle<ralf@linux-mips.org>

WBR, Sergei
