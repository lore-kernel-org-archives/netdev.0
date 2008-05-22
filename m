From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Wired behaviour with IPv6 over PPP
Date: Thu, 22 May 2008 01:49:59 -0700
Message-ID: <20080522014959.0f6191aa.akpm@linux-foundation.org>
References: <48341C0B.7010003@interway.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Matthias Cramer <matthias.cramer@interway.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40414 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764588AbYEVIui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 04:50:38 -0400
In-Reply-To: <48341C0B.7010003@interway.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 May 2008 14:56:43 +0200 Matthias Cramer <matthias.cramer@interway.ch> wrote:

> Hi All
> 
> I have a very wired behaviour when doing IPv6 over PPPoE.
> 
> The situation:
> 
> A linux box connected to a DSL Modem, on the other side is a Cisco LNS which terminates the PPP session (actually L2TP).
> I have control over both ends.
> 
> When I have net.ipv6.conf.all.forwarding set to 0 then the ppp Interface gets a IPv6 address from the Cisco via IP6CP.
> When I have net.ipv6.conf.all.forwarding set to 1 them the ppp Interface does not get an address, it has only a normal link local address.
> 
> When I start the ppp session with forwarding set to 0 I can ping out and there exists a default route to ppp0 , then I switch forwarding to 1
> the default route disappears and therefore routing does not work any longer.
> 
> Is this a known behaviour ?
> 
> Or am I doing something the wrong way ?
> 
> Kernel version is 2.6.25
> 

(cc netdev)
