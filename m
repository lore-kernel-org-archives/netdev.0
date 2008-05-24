From: Willy Tarreau <w@1wt.eu>
Subject: Re: Wired behaviour with IPv6 over PPP
Date: Sat, 24 May 2008 06:29:11 +0200
Message-ID: <20080524042911.GE6749@1wt.eu>
References: <48341C0B.7010003@interway.ch> <20080522014959.0f6191aa.akpm@linux-foundation.org> <48354318.60202@katalix.com> <4835C40B.60603@interway.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Matthias Cramer <matthias.cramer@interway.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4981 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751190AbYEXE3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 May 2008 00:29:41 -0400
Content-Disposition: inline
In-Reply-To: <4835C40B.60603@interway.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 22, 2008 at 09:05:47PM +0200, Matthias Cramer wrote:
> James Chapman wrote:
> > Andrew Morton wrote:
> >> On Wed, 21 May 2008 14:56:43 +0200 Matthias Cramer
> >> <matthias.cramer@interway.ch> wrote:
> >>> I have a very wired behaviour when doing IPv6 over PPPoE.
> >>>
> >>> The situation:
> >>>
> >>> A linux box connected to a DSL Modem, on the other side is a Cisco
> >>> LNS which terminates the PPP session (actually L2TP).
> >>> I have control over both ends.
> >>>
> >>> When I have net.ipv6.conf.all.forwarding set to 0 then the ppp
> >>> Interface gets a IPv6 address from the Cisco via IP6CP.
> >>> When I have net.ipv6.conf.all.forwarding set to 1 them the ppp
> >>> Interface does not get an address, it has only a normal link local
> >>> address.
> > 
> > What do you mean by normal link local address?
> 
> a fe80:: address, which every IPv6 enabled Interface has...
> 
> > 
> >>> When I start the ppp session with forwarding set to 0 I can ping out
> >>> and there exists a default route to ppp0 , then I switch forwarding to 1
> >>> the default route disappears and therefore routing does not work any
> >>> longer.
> > 
> > Did this work with previous kernel versions?
> 
> No, in my opinion it never worked. But I thought that pppd does it wrong
> because id never got an IPv6 address. But I had always forwarding
> enabled. Now in this case i started pppd without forwarding enabled and
> got an address.

Well, at least it has been working for years in kernel 2.4 for me with
pppd 2.4.2b3 to 2.4.4 (I've not upgraded my firewall to 2.6 yet). So
it has definitely been working at some point.

Willy

