From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] virtio_net: Recycle some more rx buffer pages
Date: Sun, 16 Nov 2008 22:40:07 -0800 (PST)
Message-ID: <20081116.224007.208486442.davem@davemloft.net>
References: <200811171344.57410.rusty@rustcorp.com.au>
	<20081116.194505.140648013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752767AbYKQGkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 01:40:07 -0500
In-Reply-To: <20081116.194505.140648013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 16 Nov 2008 19:45:05 -0800 (PST)

> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Mon, 17 Nov 2008 13:44:57 +1030
> 
> > @@ -82,6 +82,16 @@ static void give_a_page(struct virtnet_info *vi, struct 
> > page *page)
> 
> -E_EMAIL_CLIENT_NEWLINES

I got tired of sitting on my thumbs and waiting for the fixed version
of the patch, so I cleared it all out myself and added it to net-next-2.6

Even with the mail client corruption fix this thing didn't even apply
to net-next-2.6 :-(
