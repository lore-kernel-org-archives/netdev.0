From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 19:28:14 -0700
Message-ID: <20070510192814.5b71d01c@freepuppy>
References: <464370BA.3020907@hp.com>
	<20070510.133216.95506791.davem@davemloft.net>
	<46438568.1020403@hp.com>
	<20070510.140251.02302242.davem@davemloft.net>
	<46438B1D.1050802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	vladislav.yasevich@hp.com, ian.mcdonald@jandi.co.nz,
	krkumar2@in.ibm.com, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: Gagan Arneja <gaagaan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:43691 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756996AbXEKC2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 22:28:54 -0400
In-Reply-To: <46438B1D.1050802@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 May 2007 14:14:05 -0700
Gagan Arneja <gaagaan@gmail.com> wrote:

> David Miller wrote:
> > From: Rick Jones <rick.jones2@hp.com>
> > Date: Thu, 10 May 2007 13:49:44 -0700
> > 
> >> I'd think one would only do this in those situations/places where a
> >> natural "out of driver" queue develops in the first place wouldn't
> >> one?
> > 
> > Indeed.
> 
> And one builds in qdisc because your device sink is slow. There's 
> nothing inherently there in the kernel encouraging Qdisc->q to grow. 
> It's precisely these broken devices that can take advantage of cluster 
> transmits.

If you have braindead slow hardware, 
there is nothing that says your start_xmit routine can't do its own
coalescing.  The cost of calling the transmit routine is the responsibility
of the driver, not the core network code.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
