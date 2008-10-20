From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.27 [BUG-FIX] [PATCH 1/1] dccp: Port redirection support
 for DCCP
Date: Sun, 19 Oct 2008 23:37:03 -0700 (PDT)
Message-ID: <20081019.233703.12321683.davem@davemloft.net>
References: <20081018100651.GA23003@gerrit.erg.abdn.ac.uk>
	<200810181221.58863@nessa>
	<20081018152502.GJ19353@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidden@sch.bme.hu, gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38359
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751235AbYJTGh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 02:37:26 -0400
In-Reply-To: <20081018152502.GJ19353@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sat, 18 Oct 2008 12:25:02 -0300

> Em Sat, Oct 18, 2008 at 12:21:58PM +0200, KOVACS Krisztian escreveu:
> > dccp: Port redirection support for DCCP
> > 
> > Commit a3116ac5c216fc3c145906a46df9ce542ff7dcf2 from 1st October ("tcp: Port
> > redirection support for TCP") broke DCCP skb lookup by changing inet_csk_clone,
> > which is used by DCCP to generate the child socket after the handshake.
> > 
> > This patch updates DCCP to use 'loc_port' instead of 'sport', which fixes the
> > problem, and thus inheriting port redirection support via the new interface.
> > 
> > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> > Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
> 
> Good work! Better two fixes than none! :-)
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied, thanks everyone.
