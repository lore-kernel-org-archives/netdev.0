From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/core: Fix crash in
 dev_mc_sync()/dev_mc_unsync()
Date: Fri, 24 Aug 2007 23:12:16 -0700 (PDT)
Message-ID: <20070824.231216.52271731.davem@davemloft.net>
References: <20070821163129.377666902@frecb000701.frec.bull.fr>
	<46CC3840.7050300@bull.net>
	<46CD9E3C.2020002@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43013
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753304AbXHYGMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:12:17 -0400
In-Reply-To: <46CD9E3C.2020002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 23 Aug 2007 16:48:28 +0200

> Benjamin Thery wrote:
> > From: benjamin.thery@bull.net
> > Subject: net/core: Fix crash in dev_mc_sync()/dev_mc_unsync()
> > 
> > This patch fixes a crash that may occur when the routine dev_mc_sync()
> > deletes an address from the list it is currently going through. It 
> > saves the pointer to the next element before deleting the current one.
> > The problem may also exist in dev_mc_unsync().
> > 
> > Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
> 
> Looks good, thanks Benjamin.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks everyone.
