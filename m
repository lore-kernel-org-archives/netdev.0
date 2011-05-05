From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] net: call dev_alloc_name from
 register_netdevice
Date: Thu, 05 May 2011 10:58:19 -0700 (PDT)
Message-ID: <20110505.105819.59697453.davem@davemloft.net>
References: <1304162492-6606-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, mirqus@gmail.com,
	xemul@openvz.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35153
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752882Ab1EER6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 13:58:52 -0400
In-Reply-To: <1304162492-6606-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 30 Apr 2011 13:21:32 +0200

> Force dev_alloc_name() to be called from register_netdevice() by
> dev_get_valid_name(). That allows to remove multiple explicit
> dev_alloc_name() calls.
> 
> The possibility to call dev_alloc_name in advance remains.
> 
> This also fixes veth creation regresion caused by
> 84c49d8c3e4abefb0a41a77b25aa37ebe8d6b743
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

I like this change, and if some real legitimate hole is found
in it we can either quickly fix that or revert this simply.

Applied, thanks.
