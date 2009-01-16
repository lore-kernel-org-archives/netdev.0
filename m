From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: Mainline kernel OLTP performance update
Date: Thu, 15 Jan 2009 23:55:47 -0700
Message-ID: <20090116065546.GJ31013@parisc-linux.org>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com> <200901161503.13730.nickpiggin@yahoo.com.au> <20090115201210.ca1a9542.akpm@linux-foundation.org> <200901161746.25205.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, matthew.r.wilcox@intel.com,
	chinang.ma@intel.com, linux-kernel@vger.kernel.org,
	sharad.c.tripathi@intel.com, arjan@linux.intel.com,
	andi.kleen@intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:60071 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbZAPGzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 01:55:49 -0500
Content-Disposition: inline
In-Reply-To: <200901161746.25205.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2009 at 05:46:23PM +1100, Nick Piggin wrote:
> Intel's OLTP shows SLQB is "neutral" to SLAB. That is, literally within
> their measurement confidence interval. If it comes down to it, I think we
> could get them to do more runs to narrow that down, but we're talking a
> couple of tenths of a percent already.

I think I can speak with some measure of confidence for at least the
OLTP-testing part of my company when I say that I have no objection to
Nick's planned merge scheme.

I believe the kernel benchmark group have also done some testing with
SLQB and have generally positive things to say about it (Yanmin added to
the gargantuan cc).

Did slabtop get fixed to work with SLQB?

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
