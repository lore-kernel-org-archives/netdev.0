From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Eleminate HZ from NET/ROM kernel interfaces
Date: Fri, 05 May 2006 17:19:46 -0700 (PDT)
Message-ID: <20060505.171946.52849109.davem@davemloft.net>
References: <44551148.5010503@ccr.jussieu.fr>
	<20060430.172136.99531184.davem@davemloft.net>
	<20060501235235.GA18868@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pidoux@ccr.jussieu.fr, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: ralf@linux-mips.org
In-Reply-To: <20060501235235.GA18868@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Tue, 2 May 2006 00:52:35 +0100

> On Sun, Apr 30, 2006 at 05:21:36PM -0700, David S. Miller wrote:
> 
> > > With such extensive patches for netrom and rose modules that will go 
> > > into a future 2.6.x kernel, I think it would be justified to update the 
> > > following banners in af_rose.c and af_netrom.c respectively for they 
> > > appear during boot :
> > 
> > It might be worthwhile to remove the messages altogether.
> > 
> > IPV4 and the core networking used to output similar initialization
> > log messages and it really doesn't really add anything but pollute
> > the already voluminous kernel log.
> > 
> > So I say we just remove it.
> 
> Agreed, patch to remove the messages is below.
> 
>   Ralf
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks a lot Ralf.
