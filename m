From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v4] wlcore: spi: add wl18xx support
Date: Tue, 28 Jun 2016 15:56:53 -0500
Message-ID: <20160628205653.GR3737@rob-hp-laptop>
References: <1466935675-14696-1-git-send-email-eyalr@ti.com>
 <8665E2433BC68541A24DFFCA87B70F5B3613BF60@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-spi@vger.kernel.org" <linux-spi@vger.kernel.org>
To: "Reizer, Eyal" <eyalr@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8665E2433BC68541A24DFFCA87B70F5B3613BF60@DFRE01.ent.ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 26, 2016 at 10:10:54AM +0000, Reizer, Eyal wrote:
> Add support for using with both wl12xx and wl18xx.
> 
> - all wilink family needs special init command for entering wspi mode.
>   extra clock cycles should be sent after the spi init command while the
>   cs pin is high.
> - Use inverted chip select for sending a dummy 4 bytes command that
>   completes the init stage.
> 
> Signed-off-by: Eyal Reizer <eyalr@ti.com>
> ---
> v1->v2:update device tree bindings configuration
> v2->v3:revert from manual gpio manipulation. use inverted chip select instead
> for sending the extra init cycle which, achieves the same hardware purpose.
> update device tree bindings docucmentation accordingly
> v3->v4: Remove redundant data form binding documentation and fix chip select
> number mismatch in wl1271 example
> 
>  .../bindings/net/wireless/ti,wlcore,spi.txt        |  41 +++++--

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/net/wireless/ti/wlcore/spi.c               | 124 +++++++++++++++++----
>  2 files changed, 137 insertions(+), 28 deletions(-)
