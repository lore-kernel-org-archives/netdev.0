From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, take 2] TCP : keep copied_seq, rcv_wup and rcv_next
 together
Date: Thu, 22 Feb 2007 03:22:18 -0800 (PST)
Message-ID: <20070222.032218.59660260.davem@davemloft.net>
References: <20070222.012649.119274047.davem@davemloft.net>
	<200702221122.02806.dada1@cosmosbay.com>
	<200702221211.50289.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34929
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750849AbXBVLWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 06:22:20 -0500
In-Reply-To: <200702221211.50289.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 22 Feb 2007 12:11:50 +0100

> I noticed in oprofile study a cache miss in tcp_rcv_established() to read 
> copied_seq.
 ...
> As you suggested, I changed tcp_create_openreq_child() so that these fields 
> are changed together, to avoid adding a new store buffer stall.
> 
> Patch is 64bit friendly (no new hole because of alignment constraints)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Looks great, applied to my tcp-2.6 GIT tree, thanks a lot!
