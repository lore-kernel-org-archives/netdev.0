From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
	overwritten
Date: Fri, 18 Jul 2008 11:11:46 +0200
Message-ID: <20080718091146.GQ6875@elte.hu>
References: <20080717214222.GA29449@elte.hu> <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, cl@linux-foundation.org,
	davem@davemloft.net, johnpol@2ka.mipt.ru
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:40460 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753398AbYGRJMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 05:12:36 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Pekka J Enberg <penberg@cs.helsinki.fi> wrote:

> >   Object 0xf658ae70:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
> 
> It's bit unfortunate that we don't see full dump of the corruption 
> here because SLUB limits the output to 128 bytes. Ingo, you might want 
> to try this patch so that we can see all of it:

ok, applied this as a debug special to tip/out-of-tree - future 
incidents should have the full object dump.

would makes sense for upstream too i think, or increase the limit to 4K 
or so. (which is still fair to be dumped into a syslog)

	Ingo
