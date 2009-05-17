From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] drivers/net/82596.c: suppress warnings
Date: Sun, 17 May 2009 14:00:54 -0700 (PDT)
Message-ID: <20090517.140054.51504300.davem@davemloft.net>
References: <200905122107.n4CL7qqQ010642@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37063
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754203AbZEQVA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 17:00:56 -0400
In-Reply-To: <200905122107.n4CL7qqQ010642@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 12 May 2009 13:48:37 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> i386 allmodconfig:
> 
> drivers/net/82596.c: In function 'init_rx_bufs':
> drivers/net/82596.c:544: warning: cast to pointer from integer of different size

Applied.  But like Francois said, someone need to look closer into
what this driver is really doing.
