From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Sun, 30 Jan 2005 18:48:36 -0800
Message-ID: <20050130184836.17b0487b.davem@davemloft.net>
References: <20050124114853.A16971@flint.arm.linux.org.uk>
	<20050125193207.B30094@flint.arm.linux.org.uk>
	<20050127082809.A20510@flint.arm.linux.org.uk>
	<20050127004732.5d8e3f62.akpm@osdl.org>
	<16888.58622.376497.380197@robur.slu.se>
	<20050127164918.C3036@flint.arm.linux.org.uk>
	<20050127123326.2eafab35.davem@davemloft.net>
	<20050128001701.D22695@flint.arm.linux.org.uk>
	<20050127163444.1bfb673b.davem@davemloft.net>
	<20050128085858.B9486@flint.arm.linux.org.uk>
	<20050130132343.A25000@flint.arm.linux.org.uk>
	<41FD17FE.6050007@trash.net>
	<41FD18C5.6090108@trash.net>
	<41FD2043.3070303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rmk+lkml@arm.linux.org.uk, Robert.Olsson@data.slu.se, akpm@osdl.org,
        torvalds@osdl.org, alexn@dsv.su.se, kas@fi.muni.cz,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41FD2043.3070303@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 30 Jan 2005 18:58:27 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Ok, final decision: you are right :) conntrack also defragments locally
> generated packets before they hit ip_fragment. In this case the fragments
> have skb->dst set.

It's amazing how many bugs exist due to the local defragmentation and
refragmentation done by netfilter. :-)

Good catch Patrick, I'll apply this and push upstream.
