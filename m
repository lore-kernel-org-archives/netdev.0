From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (possibly
	caused by netem)
Date: Thu, 2 Jul 2009 10:12:07 +0000
Message-ID: <20090702101207.GA7056@ff.dom.local>
References: <4A4A9DD6.8060800@anarazel.de> <4A4BAD5F.7050908@gmail.com> <4A4BD384.3090407@anarazel.de> <4A4C0144.5070203@anarazel.de> <20090702093031.GC4954@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Andres Freund <andres@anarazel.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:62648 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbZGBKMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 06:12:09 -0400
Content-Disposition: inline
In-Reply-To: <20090702093031.GC4954@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 02, 2009 at 09:30:31AM +0000, Jarek Poplawski wrote:
> On Thu, Jul 02, 2009 at 02:37:24AM +0200, Andres Freund wrote:
> ...
> > So I tried - and I did not catch any lockdep output before the crash.  
> > Unfortunately I do not have another machine on the same local network to  
> > catch any messages after the crash... So I could be missing some warning  
> > (I did synchronous logging though).
> > Will check with netconsole tomorrow.
> 
> Could you try if this patch changes anything?

...and maybe CONFIG_PACKET_MMAP turned off.

Jarek P.
