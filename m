From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/3] dt-bindings: net: c_can: Update binding for clock
 and power-domains property
Date: Thu, 10 Aug 2017 11:35:58 -0500
Message-ID: <20170810163558.todxrky4f4nve57x@rob-hp-laptop>
References: <20170802201822.11532-1-fcooper@ti.com>
 <20170802201822.11532-2-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, linux@armlinux.org.uk, linux-can@vger.kernel.org,
 mkl@pengutronix.de, linux-arm-kernel@lists.infradead.org, ssantosh@kernel.org,
 wg@grandegger.com
To: Franklin S Cooper Jr <fcooper@ti.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20170802201822.11532-2-fcooper@ti.com>
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

On Wed, Aug 02, 2017 at 03:18:20PM -0500, Franklin S Cooper Jr wrote:
> CAN driver uses the clk_get_rate call to determine the frequency of the
> functional clock. OMAP based SoCs do not require the clock property since
> hwmod already handles creating a "fck" clock thats accessible to drivers.

that's

> However, this isn't the case for 66AK2G which makes the clocks property
> require for that SoC.

required

> 
> 66AK2G requires a new property. Therefore, update the binding to also make
> this property requirement clear. Also clarify that for OMAP based SoCs
> ti,hwmod is a required property.
> 
> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
> ---
>  Documentation/devicetree/bindings/net/can/c_can.txt | 13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)

Otherwise,

Acked-by: Rob Herring <robh@kernel.org>
