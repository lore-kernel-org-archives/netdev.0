From: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Thu, 14 Jan 2010 12:50:27 +0100
Message-ID: <201001141250.27287.schmto@hrz.tu-chemnitz.de>
References: <201001121432.43301.schmto@hrz.tu-chemnitz.de> <20100112.121607.39835310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jessica.hrz.tu-chemnitz.de ([134.109.132.47]:45347 "EHLO
	jessica.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751049Ab0ANLu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 06:50:29 -0500
In-Reply-To: <20100112.121607.39835310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 12 January 2010 21:16:07 you wrote:
> You can't do any of these things you are doing, I've basically been
> ignoring all of these crazy diffserv patches, they're nuts!
> 
> The TOS socket option has a meaning and behavior defined by the BSD
> sockets interface many years ago.  And you cannot and must not change
> the behavior of those system calls because applications are written to
> the current behavior and you will break them.  Protecting the new
> behavior with a kernel config option is a non-starter, it's pointless
> because no distribution is going to enable a kernel option that
> knowingly breaks applications.
> 
> And it is also possible to set the TOS field however you desire using
> what the kernel currently provides, we do not preclude proper diffserv
> support, the BSD socket interfaces allow that just fine.
okay, I noticed.

> And you can also do diffserv by classifying traffic and setting the
> TOS field using either the packet scheduler, or even netfilter.
Our company is more interested in IP DiffServ traffic accounting.
So we simply need a fast mechanism which generates IP DiffServ traffic
statistics, without setting the network interface in promiscuous mode,
(which softflowd ore tcpdump does).

So first idea was to implement a virtual file e.g. called /proc/net/ip_dscp.
If the main line peoples are not interested in, i will no longer send these
patches. 

Thanks,
Torsten

PS.: Maybe we could implement a more general mechanism to classify TOS/DiffServ 
traffic in the kernel (if needed) ?
