From: Richard Zhao <richard.zhao@freescale.com>
Subject: Re: [PATCH 1/1] net/fec: add KSZ9021RN phy fixup
Date: Tue, 13 Dec 2011 16:28:03 +0800
Message-ID: <20111213082802.GF28768@b20223-02.ap.freescale.net>
References: <1323684558-16796-1-git-send-email-richard.zhao@linaro.org>
 <CAOMZO5DNRrt7ULuBkh9y8bz2_fpCHOcSWxAbJOqTHA2Nrv1V_w@mail.gmail.com>
 <20111212135119.GE16835@b20223-02.ap.freescale.net>
 <4EE612BF.9050907@bluegiga.com>
 <20111213021008.GE28768@b20223-02.ap.freescale.net>
 <20111213023626.GA10866@S2100-06.ap.freescale.net>
 <CAB4PhKfSegpwrZbedN7KtJd+xFk1JAOCWuSFq2you5dWn9bqwA@mail.gmail.com>
 <20111213024733.GB10866@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jason Liu <liu.h.jason@gmail.com>, <patches@linaro.org>,
	<netdev@vger.kernel.org>, <s.hauer@pengutronix.de>,
	<jgq516@gmail.com>, <eric.miao@linaro.org>,
	Richard Zhao <richard.zhao@linaro.org>,
	Veli-Pekka Peltola <veli-pekka.peltola@bluegiga.com>,
	<shawn.guo@linaro.org>, Fabio Estevam <festevam@gmail.com>,
	<davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe005.messaging.microsoft.com ([213.199.154.208]:33714
	"EHLO AM1EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753420Ab1LMI2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 03:28:19 -0500
Content-Disposition: inline
In-Reply-To: <20111213024733.GB10866@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2011 at 10:47:33AM +0800, Shawn Guo wrote:
> On Tue, Dec 13, 2011 at 10:29:53AM +0800, Jason Liu wrote:
> > 2011/12/13 Shawn Guo <shawn.guo@freescale.com>:
> > > On Tue, Dec 13, 2011 at 10:10:08AM +0800, Richard Zhao wrote:
> > >> By converting to DT, machine code's becoming common too. I feel hard to
> > >> find a place. Put it in imx6q_init_machine?
> > >>
> > >> Sascha & Shawn, Could you give comments here?
> > >>
> > > I see no problem to do that by checking board compatible string and
> > > do the setup for particular board.
> > 
> > Then, you may end up having more and more fix up in the fec driver
> > when all the platforms converted to DT,
> > which will put the fec driver into mess.
> > 
> I meant we do this in imx6q_init_machine().
all right. moved to machine code.

Thanks
Richard
> 
> -- 
> Regards,
> Shawn
