From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH] net: ethernet: freescale: use devm_ioremap_resource()
Date: Tue, 14 May 2013 21:56:17 +0800
Message-ID: <CAHrpEqTQz4d65+xrWV0M6hWxqGVqb6Rfp3ZPQ4z5VExsCz14Xg@mail.gmail.com>
References: <1368473874-9569-1-git-send-email-laurent.navet@gmail.com>
	<CAHrpEqQRPiJqkFoLCGa+QmbnAa++50HRQHvw69uxN7y8zgiR3Q@mail.gmail.com>
	<CAH7P7NgZPS_AJtkaM661uGUD8rteora=EaGa4XzJZEY+vYr+6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>, joe@perches.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	kernel list <linux-kernel@vger.kernel.org>
To: Laurent Navet <laurent.navet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAH7P7NgZPS_AJtkaM661uGUD8rteora=EaGa4XzJZEY+vYr+6g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/5/14 Laurent Navet <laurent.navet@gmail.com>:
> struct resource *res)
>  {
> ...
>          if (!res || resource_type(res) != IORESOURCE_MEM) {
>                  dev_err(dev, "invalid resource\n");
>                  return ERR_PTR(-EINVAL);

Okay, thanks.
Acked
