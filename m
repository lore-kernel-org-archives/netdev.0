From: Sebastian Kuzminsky <seb@highlab.com>
Subject: Re: bug in tcp?
Date: Mon, 16 Apr 2007 22:19:58 -0600
Message-ID: <E1HdfAd-0005TL-1D@highlab.com>
References: <E1HdZgM-0001n2-F0@highlab.com> <20070416155038.3bfa5104@freekitty> <E1HdaGU-0001sZ-JS@highlab.com> <20070416163031.6b87764c@dxpl.pdx.osdl.net>
Cc: netdev@vger.kernel.org, Sebastian Kuzminsky <seb@highlab.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sccrmhc15.comcast.net ([63.240.77.85]:40536 "EHLO
	sccrmhc15.comcast.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031076AbXDQEUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 00:20:09 -0400
In-reply-to: <20070416163031.6b87764c@dxpl.pdx.osdl.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> A guess: maybe something related to a PAWS wraparound problem.
> Does turning off sysctl net.ipv4.tcp_timestamps fix it?

I just started this test, I'll let you know in 5 days.  :-/

Any other things I should try, anyone?  I'm doing the new tests under
qemu, so it's easy to run lots of tests in parallel.  The previous
reports of this bug all occurred when running natively.

I'm doing the new tests with 2.6.18, but the behavior does not seem
sensitive to the kernel version.


-- 
Sebastian Kuzminsky
