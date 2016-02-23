From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: smc911x: convert pxa dma to dmaengine
Date: Tue, 23 Feb 2016 15:15:50 -0300
Message-ID: <CAOMZO5DfQZrP-qNdPC5hJ_J+e-mX547SMq1wUC3NXWzyx84PMw@mail.gmail.com>
References: <20151202.235217.2201517065767030121.davem@davemloft.net>
	<87fuzjl69l.fsf@belgarion.home>
	<87k2mi4ysn.fsf@belgarion.home>
	<20160205.173021.1388372628450225378.davem@davemloft.net>
	<87fux6439s.fsf@belgarion.home>
	<CAE1WaKK2DqYYOTLmprbLuZVN-8--sZVyZVHgkcT4Jg7797S7HQ@mail.gmail.com>
	<8760xjzbc5.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Hitoshi Mitake <mitake.hitoshi@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8760xjzbc5.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 20, 2016 at 12:48 PM, Robert Jarzmik <robert.jarzmik@free.fr> wrote:

> Hello,
>
> I'll reping once more, to see if any of you could give this patch a try.
> So far Hitoshi doesn't have the hardware anymore, so it leaves only Guennadi and
> Fabio.
>
> If you could give it a try it would be great.
>
> For reference, the patch is here : https://lkml.org/lkml/2015/11/30/768

I finally got access to a mx53ard board, applied your patch and
managed to NFS boot without issues:

[    1.739281] smsc911x f4000000.lan9220 eth0: SMSC911x/921x
identified at 0xe0a80000, IRQ: 207

Tested-by: Fabio Estevam <fabio.estevam@nxp.com>
