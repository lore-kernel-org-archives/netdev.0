From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] [BACKPORT] [3.14.56] bnx2x: Don't notify about scratchpad parities
Date: Tue, 01 Mar 2016 06:25:45 +0000
Message-ID: <20160301062544.GG3200@kroah.com>
References: <2866398.tTChUFNQ37@rofl> <20151106173246.GA6771@kroah.com> <1686003.8SMzEu8fpg@rofl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Patrick Schaaf <netdev@bof.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail177-1.suw61.mandrillapp.com ([198.2.177.1]:5025 "EHLO
	mail177-1.suw61.mandrillapp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750771AbcCAGZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 01:25:46 -0500
Received: from pmta06.mandrill.prod.suw01.rsglab.com (127.0.0.1) by mail177-1.suw61.mandrillapp.com id hqkquk22rtkt for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 06:25:45 +0000 (envelope-from <bounce-md_30481620.56d535e9.v1-b39ff37ee88949d5b67a6f6a01bb11ef@mandrillapp.com>)
In-Reply-To: <1686003.8SMzEu8fpg@rofl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2015 at 02:37:34PM +0100, Patrick Schaaf wrote:
> On Friday 06 November 2015 09:32:46 Greg KH wrote:
> > On Thu, Nov 05, 2015 at 11:18:37AM +0100, Patrick Schaaf wrote:
> > > bnx2x: Don't notify about scratchpad parities
> > > 
> > > This is a (trivial) "backport" of ad6afbe9578d1fa26680faf78c846bd8c00d1d6e
> > > to stable kernel 3.14.56.
> > 
> > This patch isn't in 4.1 either, do you want it there as well?
> 
> Hi Greg,
> 
> I didn't see the patch in 3.14.57 or 3.14.58 - could you please consider it 
> again (for all stable kernels that don't have it)?
> 
> My three machines with bnx2x interfaces have been running file with patch 
> 3.14.56, for the last 35 days. The original problematic event (spewing a 
> million messages which are suppressed by that patch), did not reoccur so far 
> (neither did any other issue, dmesg is completely empty since boot).
> 
> best regards
>   Patrick
> 
> Related earlier posts / reports, for reference:
> 
> http://marc.info/?l=linux-netdev&m=144663711626469
> http://lists.openwall.net/netdev/2015/11/05/48

Sorry for the long delay, now queued up.

greg k-h
