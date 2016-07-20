From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCHv8] wlcore: spi: add wl18xx support
Date: Wed, 20 Jul 2016 10:02:13 +0300
Message-ID: <871t2ovll6.fsf@kamboji.qca.qualcomm.com>
References: <1468994768-23609-1-git-send-email-eyalr@ti.com>
	<8665E2433BC68541A24DFFCA87B70F5B36161990@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree\@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-spi\@vger.kernel.org" <linux-spi@vger.kernel.org>,
	Rob Herring <robh@kernel.org>
To: "Reizer\, Eyal" <eyalr@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8665E2433BC68541A24DFFCA87B70F5B36161990@DFRE01.ent.ti.com>
	(Eyal Reizer's message of "Wed, 20 Jul 2016 06:58:12 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Reizer, Eyal" <eyalr@ti.com> writes:

> Add support for using with both wl12xx and wl18xx.
>
> - all wilink family needs special init command for entering wspi mode.
>   extra clock cycles should be sent after the spi init command while the
>   cs pin is high.
> - Use inverted chip select for sending a dummy 4 bytes command that
>   completes the init stage.
>
> Signed-off-by: Eyal Reizer <eyalr@ti.com>
> Acked-by: Rob Herring <robh@kernel.org>
> ---
> v1->v2:update device tree bindings configuration
> v2->v3:revert from manual gpio manipulation. use inverted chip select instead
> for sending the extra init cycle which, achieves the same hardware purpose.
> update device tree bindings docucmentation accordingly
> v3->v4: Remove redundant data form binding documentation and fix chip select
> number mismatch in wl1271 example
> v4->v5: Rebase on top of head of wireless-drivers-next
> v5->v6: Add ACKs
> v6->v7: Mail format issues
> v7->v8: Remove redundant varaible from wlcore_probe_of

I have already applied this patch, it's too late to send a new version.
Now you need to send a new patch, on top of wireless-drivers-next, which
removes the redundant variable.

-- 
Kalle Valo
