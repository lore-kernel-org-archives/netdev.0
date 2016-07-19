From: "Reizer, Eyal" <eyalr@ti.com>
Subject: RE: [PATCH v7] wlcore: spi: add wl18xx support
Date: Tue, 19 Jul 2016 07:25:00 +0000
Message-ID: <8665E2433BC68541A24DFFCA87B70F5B36160503@DFRE01.ent.ti.com>
References: <1468911482-32560-1-git-send-email-eyalr@ti.com>
 <87poqaum6t.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-spi@vger.kernel.org" <linux-spi@vger.kernel.org>,
	"robh@kernel.org" <robh@kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>,
	Eyal Reizer <eyalreizer@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87poqaum6t.fsf@kamboji.qca.qualcomm.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > From: Eyal Reizer <eyalreizer@gmail.com>
> >
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
> 
> This looks ok in patchwork:
> 
> https://patchwork.kernel.org/patch/9235983/
> 
> Because you used ti.com in S-o-b I assume From should also use ti.com. I can
> fix that before I apply but please confirm that's really the case?
> 

Yes, S-o-b is eyalr@ti.com. 
Thank you!

--
Eyal Reizer
