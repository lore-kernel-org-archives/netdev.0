From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix NULL pointer dereference on ipx unload
Date: Thu, 08 Feb 2007 16:02:44 -0800 (PST)
Message-ID: <20070208.160244.45514749.davem@davemloft.net>
References: <20070208232828.GA25728@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933225AbXBIACp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 19:02:45 -0500
In-Reply-To: <20070208232828.GA25728@dwarf.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Bohac <jbohac@suse.cz>
Date: Fri, 9 Feb 2007 00:28:29 +0100

> Fixes a null pointer dereference when unloading the ipx module.
> 
> On initialization of the ipx module, registering certain packet
> types can fail. When this happens, unloading the module later
> dereferences NULL pointers.  This patch fixes that. Please apply.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Applied, thanks a lot Jiri.
