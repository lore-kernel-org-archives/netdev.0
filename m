From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: data received but not detected
Date: Fri, 20 Jun 2008 21:25:14 +0400
Message-ID: <20080620172513.GA16673@2ka.mipt.ru>
References: <1213740538.5771.192.camel@localhost.localdomain> <48583B37.5070708@candelatech.com> <1213743506.5771.220.camel@localhost.localdomain> <20080618062857.GA3598@2ka.mipt.ru> <1213917029.9245.86.camel@localhost.localdomain> <20080620060219.GA22784@2ka.mipt.ru> <1213981859.9245.133.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Travis Stratman <tstratman@emacinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45921 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408AbYFTRZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 13:25:11 -0400
Content-Disposition: inline
In-Reply-To: <1213981859.9245.133.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2008 at 12:10:59PM -0500, Travis Stratman (tstratman@emacinc.com) wrote:
> Initially the application was just using a blocking recvfrom() call. I
> changed to poll() and non-blocking recvfrom (MSG_DONTWAIT) today, and
> poll() always times out when the lockup occurs. I also tried using an

Can you confirm that IPSTATS_MIB_INRECEIVES MIB does not increase when
packets are sent to the frozen machine, but userspace does not receive
it?

Please also clarify this bit again: you see packets in tcpdump running
on receiving (frozen) host, but do not see them in userspace? After this
freeze happend system recvmsg/poll calls do not respond until some
activity on NIC happend? I.e. recv/poll 'unfreeze' only when something
is received (arp, icmp reply) or after sending too?

-- 
	Evgeniy Polyakov
