From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][INET_DIAG]: Fix inet_diag_lock_handler error path
Date: Mon, 28 Jan 2008 20:52:47 -0800 (PST)
Message-ID: <20080128.205247.245199332.davem@davemloft.net>
References: <20080128022050.GQ27661@ghostprotocols.net>
	<20080128110310.GA6305@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, spike@ml.yaroslavl.ru, netdev@vger.kernel.org,
	stable@kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59178
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753445AbYA2Ewa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 23:52:30 -0500
In-Reply-To: <20080128110310.GA6305@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 28 Jan 2008 22:03:10 +1100

> On Mon, Jan 28, 2008 at 12:20:50AM -0200, Arnaldo Carvalho de Melo wrote:
> > Fixes: http://bugzilla.kernel.org/show_bug.cgi?id=9825
> > 
> > The inet_diag_lock_handler function uses ERR_PTR to encode errors but
> > its callers were testing against NULL.
> 
> Thanks for catching this Arnaldo!

Applied and queued up for 2.6.24-stable, thanks!
