From: Jens Rosenboom <me@jayr.de>
Subject: [BUG] netxen: Stops working between 2.6.30 and 2.6.31-rc1
Date: Thu, 19 Nov 2009 17:39:08 +0100
Message-ID: <20091119163908.GJ14661@jayr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dhananjay Phadke <dhananjay@netxen.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout1.freenet.de ([195.4.92.91]:34684 "EHLO mout1.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756881AbZKSQjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2009 11:39:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My netxen 10G card stops working somewhere between 2.6.30 and 2.6.31-rc1. With the
newer kernel I can see packets been received on the switch it is connected to, but
the kernel doesn't report any sent packets in the interface counters and nothing
is being received either.

I've tried to bisect this, but only seems the end up with kernels that do not boot
at all because some SCSI stuff goes bad.

Any hints how to address this further? Please keep me on CC:.

Yours,
	Jens
