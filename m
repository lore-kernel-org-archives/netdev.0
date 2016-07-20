From: "Reizer, Eyal" <eyalr@ti.com>
Subject: RE: [PATCHv8] wlcore: spi: add wl18xx support
Date: Wed, 20 Jul 2016 07:04:45 +0000
Message-ID: <8665E2433BC68541A24DFFCA87B70F5B36161A17@DFRE01.ent.ti.com>
References: <1468994768-23609-1-git-send-email-eyalr@ti.com>
	<8665E2433BC68541A24DFFCA87B70F5B36161990@DFRE01.ent.ti.com>
 <871t2ovll6.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-spi@vger.kernel.org" <linux-spi@vger.kernel.org>,
	Rob Herring <robh@kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:42904 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbcGTHEv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 03:04:51 -0400
In-Reply-To: <871t2ovll6.fsf@kamboji.qca.qualcomm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> > Add support for using with both wl12xx and wl18xx.
> >
> > - all wilink family needs special init command for entering wspi mode.
> >   extra clock cycles should be sent after the spi init command while the
> >   cs pin is high.
> > - Use inverted chip select for sending a dummy 4 bytes command that
> >   completes the init stage.
> >
> > Signed-off-by: Eyal Reizer <eyalr@ti.com>
> > Acked-by: Rob Herring <robh@kernel.org>
> > ---
> > v1->v2:update device tree bindings configuration
> > v2->v3:revert from manual gpio manipulation. use inverted chip select
> instead
> > for sending the extra init cycle which, achieves the same hardware purpose.
> > update device tree bindings docucmentation accordingly
> > v3->v4: Remove redundant data form binding documentation and fix chip
> select
> > number mismatch in wl1271 example
> > v4->v5: Rebase on top of head of wireless-drivers-next
> > v5->v6: Add ACKs
> > v6->v7: Mail format issues
> > v7->v8: Remove redundant varaible from wlcore_probe_of
> 
> I have already applied this patch, it's too late to send a new version.
> Now you need to send a new patch, on top of wireless-drivers-next, which
> removes the redundant variable.
> 
Understood. Will submit shortly

Best Regards,
Eyal
