From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] vlan tag match
Date: Tue, 5 Feb 2008 08:21:50 -0800
Message-ID: <20080205082150.02e610b1@extreme>
References: <20080131210732.25f42884@extreme>
	<47A2AF6A.1060200@trash.net>
	<20080131215025.4ad118f2@extreme>
	<20080205.032040.20578647.davem@davemloft.net>
	<47A871FF.5000406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:51278 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757399AbYBEQVz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 11:21:55 -0500
In-Reply-To: <47A871FF.5000406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Feb 2008 15:26:07 +0100
Patrick McHardy <kaber@trash.net> wrote:

> David Miller wrote:
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Thu, 31 Jan 2008 21:50:25 -0800
> > 
> >> On Fri, 01 Feb 2008 06:34:34 +0100
> >> Patrick McHardy <kaber@trash.net> wrote:
> >>
> >>> Stephen Hemminger wrote:
> >>>> Provide a way to use tc filters on vlan tag even if tag is buried in
> >>>> skb due to hardware acceleration.
> >>> Looks reasonable. Would you like to add the same feature to the
> >>> flow classifier?
> >> Yes, that would be good.
> > 
> > Did that patch get posted?  I didn't see it.
> 
> 
> No, but I already added it myself. I'll post it in a new thread.
> 
> BTW, Stephen, I noticed your ematch patch doesn't mask out the
> VLAN priority which is also included in the return value of
> vlan_get_tag(), is that intentional?
> 

It seemed easier than adding two different tag related matches,
since meta match can do expressions.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
