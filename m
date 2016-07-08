From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v4] wlcore: spi: add wl18xx support
Date: Fri, 08 Jul 2016 12:57:51 +0300
Message-ID: <87bn281mg0.fsf@kamboji.qca.qualcomm.com>
References: <1466935675-14696-1-git-send-email-eyalr@ti.com>
	<8665E2433BC68541A24DFFCA87B70F5B3613BF60@DFRE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree\@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-spi\@vger.kernel.org" <linux-spi@vger.kernel.org>,
	Rob Herring <robh@kernel.org>
To: "Reizer\, Eyal" <eyalr@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39908 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176AbcGHJ56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 05:57:58 -0400
In-Reply-To: <8665E2433BC68541A24DFFCA87B70F5B3613BF60@DFRE01.ent.ti.com>
	(Eyal Reizer's message of "Sun, 26 Jun 2016 10:10:54 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
> ---
> v1->v2:update device tree bindings configuration
> v2->v3:revert from manual gpio manipulation. use inverted chip select instead
> for sending the extra init cycle which, achieves the same hardware purpose.
> update device tree bindings docucmentation accordingly
> v3->v4: Remove redundant data form binding documentation and fix chip select
> number mismatch in wl1271 example

Doesn't apply to wireless-drivers-next, please resend.

Applying: wlcore: spi: add wl18xx support
Using index info to reconstruct a base tree...
Falling back to patching base and 3-way merge...
Auto-merging drivers/net/wireless/ti/wlcore/spi.c
CONFLICT (content): Merge conflict in drivers/net/wireless/ti/wlcore/spi.c
Failed to merge in the changes.
Patch failed at 0001 wlcore: spi: add wl18xx support

-- 
Kalle Valo
