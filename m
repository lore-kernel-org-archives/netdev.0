From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : convert network timestamps to ktime_t
Date: Mon, 05 Mar 2007 00:49:38 -0800 (PST)
Message-ID: <20070305.004938.71089401.davem@davemloft.net>
References: <45EBC953.30905@cosmosbay.com>
	<20070305.000034.74747229.davem@davemloft.net>
	<45EBD30A.4030908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, linux.kernel@free.fr,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752080AbXCEItj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 03:49:39 -0500
In-Reply-To: <45EBD30A.4030908@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 05 Mar 2007 09:21:30 +0100

> I dont know very much this compat stuff, but I found 
> compat_sock_get_timestamp() only called from net/x25/af_x25.c

Good point, I thought for some reason that this function
was used for all SO_TIMESTAMP handling, but looking again
I see that the main stuff is handled in put_cmsg() compat
code.
