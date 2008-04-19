From: David Miller <davem@davemloft.net>
Subject: Re: TCP_NODELAY vs. skb coalescing
Date: Fri, 18 Apr 2008 19:31:00 -0700 (PDT)
Message-ID: <20080418.193100.207622356.davem@davemloft.net>
References: <Pine.LNX.4.64.0804190337180.12972@jikos.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jkosina@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48356
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757863AbYDSCa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 22:30:58 -0400
In-Reply-To: <Pine.LNX.4.64.0804190337180.12972@jikos.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Kosina <jkosina@suse.cz>
Date: Sat, 19 Apr 2008 03:45:02 +0200 (CEST)

> i.e. first three PUSH packets seem to be sent immediately, but after that 
> TCP switches to buffering the requests into larger chunks (1104 size, no 
> PUSH flag set), which I wouldn't expect with TCP_NODELAY. It seems to me 
> like some form of Nagle is still active.

It's hitting the congestion window.
