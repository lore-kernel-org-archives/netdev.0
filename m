From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: blackfin drivers/net/smc91x.c build error
Date: Fri, 6 Jun 2008 15:52:09 -0400
Message-ID: <8bd0f97a0806061252n1cf5ee33i40ddf9f55588e242@mail.gmail.com>
References: <20080606162212.GC2201@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Bryan Wu" <cooloney@kernel.org>, "Jeff Garzik" <jeff@garzik.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Adrian Bunk" <bunk@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932321AbYFFTwU@vger.kernel.org>
In-Reply-To: <20080606162212.GC2201@cs181133002.pp.htv.fi>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 6, 2008 at 12:22 PM, Adrian Bunk <bunk@kernel.org> wrote:
> drivers/net/smc91x.c fails as follows on blackfin:
> ...
>  CC      drivers/net/smc91x.o
> ...
> /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/smc91x.c:1863:36: error: macro "SMC_GET_MAC_ADDR" passed 2 arguments, but takes just 1
> ...

it's a known issue (been known for quite a long time actually).  Bryan
has brought this up in the past already.
-mike
