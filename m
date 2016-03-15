From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: smc911x: convert pxa dma to dmaengine
Date: Tue, 15 Mar 2016 23:56:58 +0100
Message-ID: <87wpp3mjt1.fsf@belgarion.home>
References: <20151202.235217.2201517065767030121.davem@davemloft.net>
	<87fuzjl69l.fsf@belgarion.home> <87k2mi4ysn.fsf@belgarion.home>
	<20160205.173021.1388372628450225378.davem@davemloft.net>
	<87fux6439s.fsf@belgarion.home>
	<CAE1WaKK2DqYYOTLmprbLuZVN-8--sZVyZVHgkcT4Jg7797S7HQ@mail.gmail.com>
	<8760xjzbc5.fsf@belgarion.home>
	<CAOMZO5DfQZrP-qNdPC5hJ_J+e-mX547SMq1wUC3NXWzyx84PMw@mail.gmail.com>
	<87lh5zpbaw.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Fabio Estevam <festevam@gmail.com>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Hitoshi Mitake <mitake.hitoshi@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87lh5zpbaw.fsf@belgarion.home> (Robert Jarzmik's message of
	"Thu, 03 Mar 2016 21:16:07 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Jarzmik <robert.jarzmik@free.fr> writes:

> Fabio Estevam <festevam@gmail.com> writes:
>> Tested-by: Fabio Estevam <fabio.estevam@nxp.com>
>
> Thanks Fabio for the test.
>
> I also tried with a different different approach.
>
> I built the different platforms (imx v6, etc ...) :
>  - one version (a) on a vanilla v4.5-rc2
>  - one version (b) on a vaniall v4.5-rc2 + this patch
>
> For each of the builds, I took the preprocessed output of smc911x.c, and made a
> diff between (a) and (b). The commands used were :
>  - building in [1]
>  - diffing in [2]
>
> The result is [3]. I conclude from [3] that the driver cannot break for non PXA
> platforms.
>
> With Fabio's test and this demonstration, is enough to convince you to apply
> this patch David ?
Hi David,

Can you consider this patch now it is tested please ?
