From: Harald Welte <laforge@gnumonks.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Sun, 18 Oct 2009 14:38:11 +0200
Message-ID: <20091018123811.GD27747@prithivi.gnumonks.org>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Luca Deri <deri@ntop.org>
To: Brad Doctor <brad.doctor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:60294 "EHLO
	ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753516AbZJRMrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 08:47:17 -0400
Content-Disposition: inline
In-Reply-To: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brad and Luca,

On Wed, Oct 14, 2009 at 08:33:08AM -0600, Brad Doctor wrote:
 
> On behalf of the users and developers of the PF_RING project, we would
> like to ask consideration to include the PF_RING module in the main
> line kernel.

First of all, let me state that I think the mainline support for nProbe/nTop is
something that I have been hoping for many years.  I think the performance you
are achieving is remarkable, and it would be very usable to have this
capability of high performance zero-copy packet access from userspace as a
stock feature of the Linux kernel.

The actual PF_RING implementation has been criticized a couple of times even in
the past.  One general point I remember from past discussions in the kernel
network community was that there is too much overlap with PF_PACKET, and that
this could possibly be extended with a ring buffer rather than replaced with a
fairly similar alternative mechanism.

So let's see what kind of solution the current discussion thread will come up
with... let's hope eventually we'll have the functionality in the kernel.
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
