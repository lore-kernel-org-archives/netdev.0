From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mii: Handle link state changes for forced
 modes in mii_check_media()
Date: Mon, 19 Jan 2015 15:40:09 -0500 (EST)
Message-ID: <20150119.154009.1883297001784841706.davem@davemloft.net>
References: <1421430935.1222.196.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ct178-internal@lists.codethink.co.uk, netdev@vger.kernel.org,
	linux-kernel@lists.codethink.co.uk
To: ben.hutchings@codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbbASUkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 15:40:11 -0500
In-Reply-To: <1421430935.1222.196.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Date: Fri, 16 Jan 2015 17:55:35 +0000

> mii_check_media() does not update the link (carrier) state or log link
> changes when the link mode is forced.  Drivers using the mii library
> must do this themselves, but most of them do not.
> 
> Instead of changing them all, provide a sensible default behaviour
> similar to mii_check_link() when the mode is forced.
> 
> via-rhine depends on it being a no-op in this case, so make its call
> to mii_check_media() conditional.
> 
> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>

Seems reasonable, applied, thanks Ben.
