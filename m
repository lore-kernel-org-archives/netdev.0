From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC] cpualloc: improvements to per-cpu allocation
Date: Thu, 1 Jan 2009 13:42:58 +1030
Message-ID: <200901011342.58933.rusty@rustcorp.com.au>
References: <200812310938.09912.rusty@rustcorp.com.au> <200901011056.23443.rusty@rustcorp.com.au> <Pine.LNX.4.64.0812311902050.24421@quilx.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	catalin.marinas@arm.com, akpm@linux-foundation.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59999 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753450AbZAADND (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2008 22:13:03 -0500
In-Reply-To: <Pine.LNX.4.64.0812311902050.24421@quilx.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 01 January 2009 11:33:00 Christoph Lameter wrote:
> On Thu, 1 Jan 2009, Rusty Russell wrote:
> 
> > I don't think it's a problem.  You still can't use them directly (this
> > wording was not meant to imply that), but you can now hand their addresses
> > to per_cpu_ptr() etc.  So zero-based x86-64 should Just Work.
> 
> Ok so this is going to be merged for 2.6.29? Its a good cleanup and a step
> forward to our goals.

I'm on the fence, but you've convinced me.  I'll put this in linux-next,
and if there's no damage, I'll push to Linus.  The actual conversions I'll
send via the maintainers though.

These patches have been around for a while, and though they've been polished
a little more in the last week or so the changes were mainly cosmetic.

Thanks,
Rusty.
