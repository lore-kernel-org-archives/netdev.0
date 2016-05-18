From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RESEND PATCH v6 0/6] Add Ethernet support on STM32F429
Date: Wed, 18 May 2016 11:31:17 +0200
Message-ID: <2535270.dCFPoM2olB@wuerfel>
References: <1462789899-13153-1-git-send-email-alexandre.torgue@gmail.com>
 <20160517.122527.1937360418899371800.davem@davemloft.net>
 <CALszF6AE7jkRX3sSNm=PCvEmkmZM-Sv5LxFSj7J3vMbvi8M5Cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 Kevin Hilman <khilman@kernel.org>, netdev@vger.kernel.org,
 Joachim Eastwood <manabian@gmail.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Chen-Yu Tsai <wens@csie.org>, Alexandre Torgue <alexandre.torgue@gmail.com>,
 Olof Johansson <olof@lixom.net>, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Maxime Coquelin <mcoquelin.stm32@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CALszF6AE7jkRX3sSNm=PCvEmkmZM-Sv5LxFSj7J3vMbvi8M5Cg@mail.gmail.com>
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

On Wednesday 18 May 2016 09:48:53 Maxime Coquelin wrote:
> 2016-05-17 18:25 GMT+02:00 David Miller <davem@davemloft.net>:
> > From: Maxime Coquelin <mcoquelin.stm32@gmail.com>
> > Date: Tue, 17 May 2016 11:20:16 +0200
> >
> >> Hi David,
> >>
> >> 2016-05-09 21:06 GMT+02:00 David Miller <davem@davemloft.net>:
> >>> From: Alexandre TORGUE <alexandre.torgue@gmail.com>
> >>> Date: Mon,  9 May 2016 12:31:33 +0200
> >>>
> >>>> STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
> >>>> This series:
> >>>>  -enhance current stmmac driver to control it (code already
> >>>> available) and adds basic glue for STM32F429 chip.
> >>>>  -Enable basic Net config in kernel.
> >>>
> >>> I assume this will go via the ARM tree, for the networking bits:
> >> I would expect patches 1, 2 & 3 to got via your tree, to avoid conflicts.
> >
> > I don't think putting them all via the ARM tree is going to create much
> > in the way of conflicts, and right now during the merge window offloading
> > that work from me would really help my backlog a lot.
> 
> Ok, I understand this is not the best time to pick it.
> 
> Arnd, Olof & Kevin, would you accept to pick the series in your tree?
> 

It's too late for v4.7 for us too, please pick up the arch/arm patches
in your normal stm32 tree and send them to us along with any other changes
you may have, and resend the driver by itself to netdev time after the
merge window.

The binding document can go either way, with the dts changes or with
the driver. I see no dependencies between the patches, so we just need
to land them all in v4.8.

	Arnd
