From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: COMPLETE is a poor global identifier
Date: Fri, 28 Mar 2008 10:53:21 -0700
Message-ID: <20080328105321.07873d93.akpm@linux-foundation.org>
References: <20080328032449.cbc09f3b.akpm@linux-foundation.org>
	<20080328153833.1074868a@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: i2c@lm-sensors.org, netdev@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>
To: Jean Delvare <khali@linux-fr.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41778 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753652AbYC1RyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 13:54:18 -0400
In-Reply-To: <20080328153833.1074868a@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Mar 2008 15:38:33 +0100 Jean Delvare <khali@linux-fr.org> wrote:

> Hi Andrew,
> 
> On Fri, 28 Mar 2008 03:24:49 -0700, Andrew Morton wrote:
> > 
> > powerpc allmodconfig:
> > 
> > In file included from drivers/char/rio/rio_linux.c:81:
> > drivers/char/rio/cirrus.h:202:1: warning: "COMPLETE" redefined
> > In file included from include/net/netns/ipv4.h:8,
> >                  from include/net/net_namespace.h:13,
> >                  from include/linux/seq_file.h:7,
> >                  from include/asm/machdep.h:12,
> >                  from include/asm/pci.h:17,
> >                  from include/linux/pci.h:951,
> >                  from drivers/char/rio/rio_linux.c:50:
> > include/net/inet_frag.h:28:1: warning: this is the location of the previous definition
> > 
> > In file included from drivers/char/ip2/ip2main.c:128:
> > drivers/char/ip2/i2ellis.h:608:1: warning: "COMPLETE" redefined
> > In file included from include/net/netns/ipv4.h:8,
> >                  from include/net/net_namespace.h:13,
> >                  from include/linux/seq_file.h:7,
> >                  from include/asm/machdep.h:12,
> >                  from include/asm/pci.h:17,
> >                  from include/linux/pci.h:951,
> >                  from drivers/char/ip2/ip2main.c:95:
> > include/net/inet_frag.h:28:1: warning: this is the location of the previous definition
> > 
> > 
> > they should all be renamed.  These can cause runtime failures, so it's not
> > a trivial thing.
> 
> How is this related to i2c?

uh, I guess at 3:24AM ip2 and i2c look the same.
