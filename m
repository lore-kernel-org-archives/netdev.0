From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 2/2] drivers/net/82596.c: suppress warnings
Date: Thu, 14 May 2009 00:29:09 +0200
Message-ID: <20090513222909.GA4118@electric-eye.fr.zoreil.com>
References: <200905122107.n4CL7qqQ010642@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52769 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755762AbZEMW2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 18:28:44 -0400
Content-Disposition: inline
In-Reply-To: <200905122107.n4CL7qqQ010642@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org <akpm@linux-foundation.org> :
> i386 allmodconfig:
> 
> drivers/net/82596.c: In function 'init_rx_bufs':
> drivers/net/82596.c:544: warning: cast to pointer from integer of different size
> drivers/net/82596.c:545: warning: cast to pointer from integer of different size
[...]
> drivers/net/82596.c: In function 'i596_interrupt':
> drivers/net/82596.c:1404: warning: cast to pointer from integer of different size
> 
> (ugh)

I may sound like Pavlov's best friend but the use of virt_to_bus and
the 90's look of this (old) driver make me wonder if the use of so
many pointers is right in the first place. Ought some of those be
turned into plain u32 instead ?

-- 
Ueimor
