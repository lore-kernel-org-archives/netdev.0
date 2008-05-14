From: David Miller <davem@davemloft.net>
Subject: Re: [patch 8/8] isdn/capi: return proper errnos on module init
Date: Wed, 14 May 2008 16:55:07 -0700 (PDT)
Message-ID: <20080514.165507.248259691.davem@davemloft.net>
References: <200805142319.m4ENJlhA026572@imap1.linux-foundation.org>
	<20080514.164223.201897276.davem@davemloft.net>
	<20080514164931.5782f897.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcin.slusarz@gmail.com, kkeil@suse.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751181AbYENXzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:55:13 -0400
In-Reply-To: <20080514164931.5782f897.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 14 May 2008 16:49:31 -0700

> On Wed, 14 May 2008 16:42:23 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: akpm@linux-foundation.org
> > Date: Wed, 14 May 2008 16:19:46 -0700
> > 
> > > From: Marcin Slusarz <marcin.slusarz@gmail.com>
> > > 
> > > cdebug_init() is called from kcapi_init() which is module initialization
> > > function, so it must return negative values on errors.
> > > 
> > > Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
> > > Acked-by: Karsten Keil <kkeil@suse.de>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Acked-by: David S. Miller <davem@davemloft.net>
> 
> hm, what does this mean?  I was hoping for "applied, thanks" ;)

Sorry, I thought you were dumping to Linus, I didn't
read the to:/cc:
