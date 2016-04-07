From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH RFC 1/5] net: phy: sun8i-h3-ephy: Add bindings for
 Allwinner H3 Ethernet PHY
Date: Thu, 7 Apr 2016 12:57:25 -0500
Message-ID: <20160407175725.GG32257@rob-hp-laptop>
References: <1459786954-12649-1-git-send-email-wens@csie.org>
 <1459786954-12649-2-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, Pawel Moll <pawel.moll@arm.com>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, LABBE Corentin <clabbe.montjoie@gmail.com>,
 Kumar Gala <galak@codeaurora.org>,
 Maxime Ripard <maxime.ripard@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1459786954-12649-2-git-send-email-wens@csie.org>
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

On Tue, Apr 05, 2016 at 12:22:30AM +0800, Chen-Yu Tsai wrote:
> The Allwinner H3 SoC incorporates an Ethernet PHY. This is enabled and
> configured through a memory mapped hardware register.
> 
> This same register also configures the MAC interface mode and TX clock
> source. Also covered by the register, but not supported in these bindings,
> are TX/RX clock delay chains and inverters, and an RMII module.
> 
> Signed-off-by: Chen-Yu Tsai <wens@csie.org>
> ---
>  .../bindings/net/allwinner,sun8i-h3-ephy.txt       | 44 ++++++++++++++++++++++
>  1 file changed, 44 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt

Acked-by: Rob Herring <robh@kernel.org>
