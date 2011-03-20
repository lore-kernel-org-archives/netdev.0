From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] socket: increase default maximum listen queue length
Date: Sat, 19 Mar 2011 21:41:00 -0700 (PDT)
Message-ID: <20110319.214100.183043711.davem@davemloft.net>
References: <1300585811-21566-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52561
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750903Ab1CTEkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 00:40:22 -0400
In-Reply-To: <1300585811-21566-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Sun, 20 Mar 2011 02:50:11 +0100

> For real server work the defacto sysctl_somaxconn limit seems inadequate:
> 
>     Experiments with real servers show, that it is absolutely not enough
>     even at 100conn/sec. 256 cures most of problems.

What in the world is a server running on multi-GHZ cpus doing such
that it cannot accept() fast enough to keep up with a 100 connections
per second?

We were handling that just fine 10+ years ago.

The math simply doesn't add up.

Either your numbers are wrong or the server design is brain-dead.
