From: Haavard Skinnemoen <hskinnemoen@atmel.com>
Subject: Re: [PATCH] macb: Call phy_disconnect on removing
Date: Wed, 16 Apr 2008 00:57:15 -0400
Message-ID: <20080416005715.738ca969@siona.local>
References: <20080410.233007.41197293.anemo@mba.ocn.ne.jp>
	<48005E6E.3010802@garzik.org>
	<20080415015331.b6ab8963.akpm@linux-foundation.org>
	<20080416.013520.74752756.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	stable@kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-132.atmel.no ([80.232.32.132]:62926 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751151AbYDPE6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 00:58:19 -0400
In-Reply-To: <20080416.013520.74752756.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Apr 2008 01:35:20 +0900 (JST)
Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:

> On Tue, 15 Apr 2008 01:53:31 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > applied  
> > 
> > Needed in 2.6.24.x as well, I think?  
> 
> Yes, though I suppose this driver is not widely used as a module.
> CC-ed to stable@kernel.org.

Yes, I agree it's needed in -stable too. You're probably right that
this driver isn't widely used as a module -- I like to have at least
the possibility of running nfsroot on the kernels I build.

Thanks a lot, Atsushi, Jeff and Andrew for taking care of this while
I'm being unresponsive.

Haavard
