From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v3 2/6] ARM: dts: armada-xp-98dx3236: combine dfx server
 nodes
Date: Mon, 27 Feb 2017 08:49:48 -0600
Message-ID: <20170227144948.arndiwidghwd7pth@rob-hp-laptop>
References: <20170216085041.28337-1-chris.packham@alliedtelesis.co.nz>
 <20170216085041.28337-3-chris.packham@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Lunn <andrew@lunn.ch>,
 Jason Cooper <jason@lakedaemon.net>, devicetree@vger.kernel.org,
 netdev@vger.kernel.org, Russell King <linux@armlinux.org.uk>,
 linux-kernel@vger.kernel.org,
 Gregory Clement <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Chris Packham <chris.packham@alliedtelesis.co.nz>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20170216085041.28337-3-chris.packham@alliedtelesis.co.nz>
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

On Thu, Feb 16, 2017 at 09:50:36PM +1300, Chris Packham wrote:
> Rather than having a separate node for the dfx server add a reg property
> to the parent node. This give some compatibility with the Marvell
> supplied SDK.
> 
> As no upstream driver currently exists for this block and support for
> this SoC is still quite fresh in the kernel it should not be necessary
> to retain a backwards compatible binding.
> 
> Signed-off-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
> ---
> 
> Notes:
>     Changes in v2:
>     - none
>     Changes in v3:
>     - update commit message to indicate backwards incompatible change and
>       why it's OK
>     - retain dfx-server compatible string
> 
>  Documentation/devicetree/bindings/net/marvell,prestera.txt | 13 +++++--------
>  arch/arm/boot/dts/armada-xp-98dx3236.dtsi                  | 10 +++-------
>  2 files changed, 8 insertions(+), 15 deletions(-)

Acked-by: Rob Herring <robh@kernel.org>
