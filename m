From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Wed, 29 Aug 2007 15:30:42 +0200
Message-ID: <20070829133042.GA4038@ff.dom.local>
References: <46D53D9C.5070204@bigtelecom.ru> <20070829113447.GA3575@ff.dom.local> <20070829121408.GB3575@ff.dom.local> <46D56C60.3060702@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:35422 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755617AbXH2N3X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 09:29:23 -0400
Content-Disposition: inline
In-Reply-To: <46D56C60.3060702@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 29, 2007 at 04:53:52PM +0400, Badalian Vyacheslav wrote:
...
> we have this kernel panic (then delete HTB) at all 2.6.18-x versions.
> on older kernel (2.6.x) we have another panic (then delete tc filter)... 
> summary we have TC panics 1 year ago ;) Sysctl option "reboot on panic" 

I'm not sure: do you mean it was less often? Did you try to report it
here? (Delete HTB: qdisc or classes?)

> save us. Now we up 2 backup computers and may try any patches to fix 
> this problem.
> 
> Also on 2.6.22 have strange dead. Black screen, no response to keyboard, 
> no info in netconsole, HardDisk led is stable red. "Black Dead"
> 

Yes, with all black it could be harder... Maybe 'set -x' at the
beginning (after #!/bin/sh line) of a script could manage to save
something before reboot or send with netconsole (but there could be
a lot of this with a large script...). Netconsole could be troublesome
too. One HTB deadlock problem during similar deleting was fixed in
2.6.23-rc (HTB timer problem) but the log was different. Anyway,
we probably need some more information (and trying).

Jarek P.
