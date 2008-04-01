From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 2/6][SOCK][NETNS]: Add a struct net argument
 to sock_prot_inuse_add and _get.
Date: Mon, 31 Mar 2008 20:19:07 -0700 (PDT)
Message-ID: <20080331.201907.74454891.davem@davemloft.net>
References: <47F0D511.2090403@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58979
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753323AbYDADTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 23:19:06 -0400
In-Reply-To: <47F0D511.2090403@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 31 Mar 2008 16:12:01 +0400

> This counter is about to become per-proto-and-per-net, so we'll need 
> two arguments to determine which cell in this "table" to work with.
> 
> All the places, but proc already pass proper net to it - proc will be
> tuned a bit later.
> 
> Some indentation with spaces in proc files is done to keep the file
> coding style consistent.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
