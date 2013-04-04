From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net-next] tcp: add a global sysctl to control TCP delayed ack
Date: Fri, 5 Apr 2013 00:48:10 +0200
Message-ID: <20130404224810.GE23056@order.stressinduktion.org>
References: <1365070560-11544-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51953 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765161Ab3DDWsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 18:48:11 -0400
Content-Disposition: inline
In-Reply-To: <1365070560-11544-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 04, 2013 at 06:16:00PM +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> Change from RFC:
> * make the sysctl per netns
> 
> According to previous discussion, it seems there is no
> reasonable heuristics.
> 
> Similar to TCP_QUICK_ACK option, but for people who can't
> modify the source code and still wants to control
> TCP delayed ACK behavior.
> 
> David, do you still have any objection?

I totally understand the objections that were given regarding this
patch. But for defense of this patch we also provide a knob to disable
slow start after idle, which from my point of view is as "evil" as
this change.

Btw I think we should make tcp_slow_start_after_idle namespace aware, too.
