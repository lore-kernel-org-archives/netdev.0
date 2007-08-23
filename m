From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/1] net/core: Fix crash in dev_mc_sync()/dev_mc_unsync()
Date: Thu, 23 Aug 2007 16:48:28 +0200
Message-ID: <46CD9E3C.2020002@trash.net>
References: <20070821162922.149199466@frecb000701.frec.bull.fr> <20070821163129.377666902@frecb000701.frec.bull.fr> <46CC3840.7050300@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Benjamin Thery <benjamin.thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56117 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764192AbXHWOuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 10:50:06 -0400
In-Reply-To: <46CC3840.7050300@bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Thery wrote:
> From: benjamin.thery@bull.net
> Subject: net/core: Fix crash in dev_mc_sync()/dev_mc_unsync()
> 
> This patch fixes a crash that may occur when the routine dev_mc_sync()
> deletes an address from the list it is currently going through. It 
> saves the pointer to the next element before deleting the current one.
> The problem may also exist in dev_mc_unsync().
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Looks good, thanks Benjamin.

Acked-by: Patrick McHardy <kaber@trash.net>

