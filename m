From: Gabriel Paubert <paubert@iram.es>
Subject: Re: [P.A. Semi] Does the ethernet interface work on your Electra,
 Chitra, Nemo, and Athena board?
Date: Mon, 30 Nov 2015 19:12:18 +0100
Message-ID: <20151130181217.GA15921@visitor2.iram.es>
References: <565AF986.9060106@xenosoft.de>
 <CAOJe8K1911vDjMe9m_1vY6DSGpOk0TmL96Qf1whuNFXxHJesGw@mail.gmail.com>
 <565C1B55.4020207@xenosoft.de>
 <565C8287.7090209@xenosoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denis Kirjanov <kda@linux-powerpc.org>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rudy.puc.rediris.es ([130.206.18.132]:47823 "EHLO
	rudy.puc.rediris.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754186AbbK3SaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 13:30:09 -0500
Content-Disposition: inline
In-Reply-To: <565C8287.7090209@xenosoft.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 30, 2015 at 06:08:23PM +0100, Christian Zigotzky wrote:
> Hi All,
> 
> I have tested the PA Semi Ethernet with the kernels 4.2.3 and 4.3.0
> today. With the kernel 4.2.3 it works but with the kernel 4.3.0
> final it doesn't work.
> 
> After that I tested some git kernels and release candidates of 4.3.
> 
> Kernel 4.3 git from Tue Sep 01, 2015 -> PA Semi Ethernet works
> Kernel 4.3 git from Wed Sep 02, 2015 -> PA Semi Ethernet works
> Kernel 4.3 git from Thu Sep 03, 2015 -> PA Semi Ethernet works
> Kernel 4.3 git from Fri Sep 04, 2015 -> PA Semi Ethernet doesn't
> work (Merge tag 'powerpc-4.3-1': https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ff474e8ca8547d09cb82ebab56d4c96f9eea01ce)
> Kernel 4.3 git from Sat Sep 05, 2015 -> PA Semi Ethernet doesn't work
> Kernel 4.3 git from Mon Sep 07, 2015 -> PA Semi Ethernet doesn't work
> Kernel 4.3 git from Wed Sep 09, 2015 -> PA Semi Ethernet doesn't work
> Kernel 4.3 git from Fri Sep 11, 2015 -> PA Semi Ethernet doesn't work
> Kernel 4.3 RC1 from Sun Sep 13, 2015 -> PA Semi Ethernet doesn't work
> Kernel 4.3 RC2 from Mon Sep 21, 2015 -> PA Semi Ethernet doesn't work
> 
> The problematic commit must be between Thu Sep 03, 2015 at 09:37 AM
> (UTC +2) and Fri Sep 04, 2015 at 7:38 PM (UTC +2) in the linux git.
> 
> Linux git: Between https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/log/?ofs=15500
> and https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/log/?ofs=15200.
> 
> Maybe https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ff474e8ca8547d09cb82ebab56d4c96f9eea01ce.

Unless I miss something, that's the kind of regression that "git bisect" is 
designed to find.

    Cheers,
    Gabriel
