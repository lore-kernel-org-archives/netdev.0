From: adobriyan@gmail.com
Subject: Re: atl1: WARNING at net/sched/sch_generic.c:221
Date: Thu, 21 Aug 2008 16:04:09 +0400
Message-ID: <20080821120409.GA2226@x200.localdomain>
References: <20080821115849.GA2126@x200.localdomain> <20080821.045910.61585911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jcliburn@gmail.com, csnook@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:47297 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbYHUMCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:02:46 -0400
Received: by mu-out-0910.google.com with SMTP id w8so1274067mue.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 05:02:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821.045910.61585911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 04:59:10AM -0700, David Miller wrote:
> From: adobriyan@gmail.com
> Date: Thu, 21 Aug 2008 15:58:49 +0400
> 
> > This message happens more or less every reboot, sometimes cable unplug/plug is needed
> > to restore connectivity, otherwise card is working fine.
> 
> What kernel version.... no, I can figure it out via osmosis never mind!
> :-)

WARN already prints kernel version. ;-)

[ 2086.052503] Pid: 0, comm: swapper Not tainted 2.6.27-rc4-netns-nf #4
						 ^^^^^^^^^^^^^^^^^^^

And before you ask, "-netns-nf" part doesn't matter, it happens with
strictly mainline kernels too and started around multiqueue TX changes,
IIRC.

