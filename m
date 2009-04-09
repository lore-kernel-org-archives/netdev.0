From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.30-rc1: e1000: list_add corruption
Date: Thu, 9 Apr 2009 08:01:59 +0000
Message-ID: <20090409080159.GA5845@ff.dom.local>
References: <20090408.212040.184687004.davem@davemloft.net> <20090409071242.GA5515@ff.dom.local> <20090409.005106.96791990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: a.beregalov@gmail.com, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:34719 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755928AbZDIICI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 04:02:08 -0400
Content-Disposition: inline
In-Reply-To: <20090409.005106.96791990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 09, 2009 at 12:51:06AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 9 Apr 2009 07:12:42 +0000
> 
> > On 09-04-2009 06:20, David Miller wrote:
> >> From: Alexander Beregalov <a.beregalov@gmail.com>
> >> Date: Thu, 9 Apr 2009 08:16:00 +0400
> >> 
> >>> The host has two interfaces
> >>> eth0 - e1000, eth1 - forcedeth.
> >>> Both are not working after that messages.
> >> 
> >> It looks like the NAPI pending list is being modified in an illegal
> >> state by forcedeth, and mid-stream to a list_del() an e1000 interrupt
> >> comes in and this tries to schedule the e1000 NAPI context and we get
> >> list corruption.
> > 
> > Good point! Feel free to send a patch. ;-)
> 
> A real shame, since I sent that analysis in hoping someone else
> would do the rest of the digging and write the fix. :-/

Hmm... What rest? Alexander?

Jarek P.
