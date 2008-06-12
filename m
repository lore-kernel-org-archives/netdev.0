From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 05/13] ipg: fix receivemode IPG_RM_RECEIVEMULTICAST{,HASH}
 in ipg_nic_set_multicast_list()
Date: Wed, 11 Jun 2008 22:50:43 -0400
Message-ID: <48508F03.4070506@garzik.org>
References: <200806092333.m59NXoog014679@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roel.kluin@gmail.com, romieu@fr.zoreil.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45509 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755480AbYFLCur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2008 22:50:47 -0400
In-Reply-To: <200806092333.m59NXoog014679@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Roel Kluin <roel.kluin@gmail.com>
> 
> The branches are dead code.  even when dev->flag IFF_MULTICAST (defined
> 0x1000) is set, dev->flags & IFF_MULTICAST & [boolean] always evaluates to
> 0.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

applied 5-6



