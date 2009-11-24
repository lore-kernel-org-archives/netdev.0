From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Tue, 24 Nov 2009 13:46:25 +0000
Message-ID: <20091124134624.GA9474@ff.dom.local>
References: <81bfc67a0911232217n41b9ac02w3b7770b789e5d209@mail.gmail.com> <20091124111946.GA7883@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:40818 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932911AbZKXNq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 08:46:28 -0500
Content-Disposition: inline
In-Reply-To: <20091124111946.GA7883@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2009 at 11:19:46AM +0000, Jarek Poplawski wrote:
...
> Alas it's not all information I asked. E.g. "netstat -s before faulty
> kernel" and "netstat -s after faulty kernel" seem to be the same file:
> netstat_after.slave4.log.gz.

On the other hand, there is a lot of tcp retransmits there:

Tcp:
    17 active connections openings
    0 passive connection openings
    14 failed connection attempts
    0 connection resets received
    0 connections established
    45 segments received
    49 segments send out
    19 segments retransmited
    0 bad segments received.
    19 resets sent

So it might point at the driver yet. It would be interesting to see
more of this: could you repeat "netstat -s" and "ethtool -S eth0"
after rebooting with both kernels and doing a few minutes of similar
tcp activities (against the router or some other "good" site). Btw,
please remind us the exact kernel versions. If you can, try 2.6.32-rc8
instead of 2.6.31.

Jarek P.
