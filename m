From: Marc D Ronell <mronell@alumni.upenn.edu>
Subject: Re: Network access fails unless tcpdump is running?
Date: Fri, 02 Mar 2007 15:53:39 -0500
Message-ID: <87abyv74fg.fsf@corps.glidepath.invalid>
References: <87y7mg4vm7.fsf@corps.glidepath.invalid> <20070301201307.GC3199@gospo.rdu.redhat.com>
 <87ps7s4rbx.fsf@corps.glidepath.invalid>
 <20070301212245.GD3199@gospo.rdu.redhat.com>
 <87hct44ka1.fsf@corps.glidepath.invalid>
 <20070302202658.GA15151@core2.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:38211 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965612AbXCBUyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 15:54:23 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1HNElc-0003mb-1F
	for netdev@vger.kernel.org; Fri, 02 Mar 2007 21:54:16 +0100
Received: from pool-71-255-169-178.bstnma.east.verizon.net ([71.255.169.178])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 21:54:16 +0100
Received: from mronell by pool-71-255-169-178.bstnma.east.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 21:54:16 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Andy Gospodarek" <gospo@redhat.com> writes:

>
> Any chance you can boot back to the old kernel (the one where is was
> working) and run and ethtool -i eth0 on that one to see what version of
> the driver was used there?  It's hard to know what may have changed
> between the 2 versions of the driver since I don't know the starting
> point.
>
> It's also hard to know if this is fixed already since you aren't running
> the latest upstream kernel.  Downloading, building, and testing the
> latest from kernel.org would be a good way to know if this is already
> fixed.
>

I had already loaded,  compiled, and tested linux-2.6.20.1.  There was
no change with the newer kernel.  Network connections only worked when
tcpdump was running.

Similar for booting with an  older kernel 2.6.17.  I think the problem
is not with the kernel, but with other system software.  It could take
a while to debug, so I am just rebuilding.

Thanks for your help.

marc


