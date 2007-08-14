From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] xen-netfront: Avoid deref'ing skbafter it is potentially
 freed.
Date: Tue, 14 Aug 2007 01:51:17 -0400
Message-ID: <46C142D5.6050800@garzik.org>
References: <46C0B6FD.7020701@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, Keir Fraser <keir@xensource.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52094 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S943188AbXHNFvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:51:20 -0400
In-Reply-To: <46C0B6FD.7020701@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> xennet_tx_bug_gc can free the skb before we use it, so make sure we don't.
> 
> Jeff, this is -rc material.
> 
> Signed-off-by: Keir Fraser <keir@xensource.com>
> Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
> Cc: Jeff Garzik <jeff@garzik.org>

applied


