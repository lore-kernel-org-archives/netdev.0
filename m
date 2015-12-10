From: Patrick Schaaf <netdev@bof.de>
Subject: Re: [PATCH] [BACKPORT] [3.14.56] bnx2x: Don't notify about scratchpad parities
Date: Thu, 10 Dec 2015 14:37:34 +0100
Message-ID: <1686003.8SMzEu8fpg@rofl>
References: <2866398.tTChUFNQ37@rofl> <20151106173246.GA6771@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mars.intermailgate.com ([80.242.145.70]:54367 "EHLO
	mars.intermailgate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbbLJNhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 08:37:40 -0500
In-Reply-To: <20151106173246.GA6771@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 06 November 2015 09:32:46 Greg KH wrote:
> On Thu, Nov 05, 2015 at 11:18:37AM +0100, Patrick Schaaf wrote:
> > bnx2x: Don't notify about scratchpad parities
> > 
> > This is a (trivial) "backport" of ad6afbe9578d1fa26680faf78c846bd8c00d1d6e
> > to stable kernel 3.14.56.
> 
> This patch isn't in 4.1 either, do you want it there as well?

Hi Greg,

I didn't see the patch in 3.14.57 or 3.14.58 - could you please consider it 
again (for all stable kernels that don't have it)?

My three machines with bnx2x interfaces have been running file with patch 
3.14.56, for the last 35 days. The original problematic event (spewing a 
million messages which are suppressed by that patch), did not reoccur so far 
(neither did any other issue, dmesg is completely empty since boot).

best regards
  Patrick

Related earlier posts / reports, for reference:

http://marc.info/?l=linux-netdev&m=144663711626469
http://lists.openwall.net/netdev/2015/11/05/48
