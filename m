From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Sun, 6 Jan 2008 04:50:01 +0100
Message-ID: <20080106035001.GA10129@one.firstfloor.org>
References: <477FF149.4070609@linux.intel.com> <p733atbr5q4.fsf@bingen.suse.de> <47804B91.1050709@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49138 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752889AbYAFDru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 22:47:50 -0500
Content-Disposition: inline
In-Reply-To: <47804B91.1050709@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 05, 2008 at 07:31:29PM -0800, Arjan van de Ven wrote:
> Andi Kleen wrote:
> >Arjan van de Ven <arjan@linux.intel.com> writes:
> >>Rank 4: remove_proc_entry
> >>	Was also ranked 4th last week
> >>	Only in tainted oopses
> >>	Reported 3 times (12 total reports)
> >>	More info: 
> >>	http://www.kerneloops.org/search.php?search=remove_proc_entry
> >
> >Likely a broken module_exit() function that corrupts the list. To track
> >these down it might be useful to keep a list of recently unloaded modules
> >and dump these too in the oops module list with a special flag.
> >
> I suspect that simply printing the currently unloading module will catch 
> 90%+ already;

There are a few cases where the corruption is only visible next time
someone accesses the list. So a small ring buffer might make sense.

-Andi

