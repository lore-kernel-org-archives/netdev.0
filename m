From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH 16/16] drivers/net/qlcnic: Use available error codes
Date: Mon, 16 Aug 2010 21:05:27 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008162105120.12526@ask.diku.dk>
References: <Pine.LNX.4.64.1008161828520.19313@ask.diku.dk> <20100816183540.GE645@bicker>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100816183540.GE645@bicker>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Aug 2010, Dan Carpenter wrote:

> On Mon, Aug 16, 2010 at 06:29:13PM +0200, Julia Lawall wrote:
> > From: Julia Lawall <julia@diku.dk>
> > 
> > The error code is stored in the variable err, but it is the variable ret
> > that is returned instead.  So store the error code in ret.  Err is then
> > useless.
> 
> Could you redo this for the latest git?  (Sorry, I recently made the
> problem slightly worse by adding another "err = -ENOMEM;")...

Sure.  I'll send it shortly.

julia
