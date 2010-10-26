From: Joe Buehler <aspam@cox.net>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Tue, 26 Oct 2010 09:53:45 -0400
Message-ID: <4CC6DD69.4020502@cox.net>
References: <loom.20101012T185411-307@post.gmane.org>	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>	 <1287805487.2658.5.camel@edumazet-laptop>	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net>	 <1287851745.2658.364.camel@edumazet-laptop>  <4CC6D7CC.5040608@cox.net> <1288100208.3169.112.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtao103.cox.net ([68.230.240.9]:51823 "EHLO
	eastrmmtao103.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512Ab0JZNxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 09:53:47 -0400
In-Reply-To: <1288100208.3169.112.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Well, it would be surprising this being wrong and crash only once in a
> while in fib_rules_lookup

> Did you tried my last patch ?

There was a patch to the kernel by David Daney back in January to
improve performance of Octeon memory barriers.  The patch changes the
generic MIPS barrier code to introduce optimizations for Octeon.  The
LINUX version I am using is from the Octeon SDK and appears to have an
early version of this patch.  It's broken however -- the Jan patch has
proper SYNCW instructions in smp_wmb while the SDK version does not.

I have made your changes but will also fold in this change, then start
some load testing.

The real-time scheduler is broken in the LINUX I am using -- I get
kernel crashes -- and I would be most happy if the SYNCW fix fixed that
also.

Joe Buehler

