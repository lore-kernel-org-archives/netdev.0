From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] socket: increase default maximum listen queue
 length
Date: Sun, 20 Mar 2011 16:09:06 -0700 (PDT)
Message-ID: <20110320.160906.112595807.davem@davemloft.net>
References: <20110320121414.GC3038@nuttenaction>
	<1300662282-24741-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50922
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751385Ab1CTXI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 19:08:28 -0400
In-Reply-To: <1300662282-24741-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Mon, 21 Mar 2011 00:04:41 +0100

> For real server work the defacto sysctl_somaxconn limit seems inadequate:
> 
>     Experiments with real servers show, that it is absolutely not enough
>     even at 100conn/sec. 256 cures most of problems.

Absolutely no context is provided for this number.

What's the RTT?  How fast are the cpus?  etc.

You must tell the whole story in order to justify these changes
properly.
