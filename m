From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Eleminate HZ from NET/ROM kernel interfaces
Date: Sun, 30 Apr 2006 17:21:36 -0700 (PDT)
Message-ID: <20060430.172136.99531184.davem@davemloft.net>
References: <20060429141613.GA2811@linux-mips.org>
	<44551148.5010503@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: pidoux@ccr.jussieu.fr
In-Reply-To: <44551148.5010503@ccr.jussieu.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Date: Sun, 30 Apr 2006 21:34:32 +0200

> Ralf Baechle wrote :
> 
> > Convert all NET/ROM sysctl time values from jiffies to ms as units.
> > 
> > Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> > 
> 
> With such extensive patches for netrom and rose modules that will go 
> into a future 2.6.x kernel, I think it would be justified to update the 
> following banners in af_rose.c and af_netrom.c respectively for they 
> appear during boot :

It might be worthwhile to remove the messages altogether.

IPV4 and the core networking used to output similar initialization
log messages and it really doesn't really add anything but pollute
the already voluminous kernel log.

So I say we just remove it.
