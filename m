From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC] cpualloc: improvements to per-cpu allocation
Date: Wed, 31 Dec 2008 19:03:00 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0812311902050.24421@quilx.com>
References: <200812310938.09912.rusty@rustcorp.com.au>
 <Pine.LNX.4.64.0812311717050.22685@quilx.com> <200901011056.23443.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	catalin.marinas@arm.com, akpm@linux-foundation.org,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi025.sbcis.sbc.com ([207.115.36.54]:36312 "EHLO
	nlpi025.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377AbZAABEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 20:04:12 -0500
In-Reply-To: <200901011056.23443.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Jan 2009, Rusty Russell wrote:

> I don't think it's a problem.  You still can't use them directly (this
> wording was not meant to imply that), but you can now hand their addresses
> to per_cpu_ptr() etc.  So zero-based x86-64 should Just Work.

Ok so this is going to be merged for 2.6.29? Its a good cleanup and a step
forward to our goals.


