From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/3] netfilter: Use pr_<level> and pr_fmt
Date: Thu, 11 Jun 2009 10:44:59 -0700
Message-ID: <1244742299.30185.7.camel@Joe-Laptop.home>
References: <cover.1244705154.git.joe@perches.com>
	 <alpine.LSU.2.00.0906111303260.1795@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0906111303260.1795@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-06-11 at 13:04 +0200, Jan Engelhardt wrote:
> On Thursday 2009-06-11 09:40, Joe Perches wrote:
> 
> >Many of the [wretched grammar removed] netfilter printk
> >calls do not have KERN_<level> prefixes.
[]
> >Remove the function names in printk strings and add
> >#define pr_fmt(fmt) "%s:%s " fmt, KBUILD_MODNAME, __func__
> 
> Hm I had wished there was a better way than to replicate
> this define over all Netfilter files.
> Perhaps stuff it into an include.

Maybe standardize the netfilter includes a bit later?

Patrick, is this patch set concept acceptable at all?

