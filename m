From: David Lamparter <equinox@diac24.net>
Subject: Re: NET_NS: unregister_netdevice: waiting for lo to become free
 (adding ipv6 address to interface)
Date: Fri, 22 Oct 2010 14:48:58 +0200
Message-ID: <20101022124858.GA719746@jupiter.n2.diac24.net>
References: <20100710235323.5336f627@xenia.leun.net>
 <20100711192939.1c25dcaf@xenia.leun.net>
 <20100804153543.56f6ecad@xenia.leun.net>
 <20100804214618.GA6289@kroah.com>
 <20100805001105.5a3453ed@xenia.leun.net>
 <m1lj8l29zm.fsf@fess.ebiederm.org>
 <20100805112538.60a46cb1@xenia.leun.net>
 <m1y6clz8ta.fsf_-_@fess.ebiederm.org>
 <20100805134707.0442a7b1@xenia.leun.net>
 <20101021171532.54af5e97@xenia.leun.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Michael Leun <lkml20100708@newton.leun.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:39926 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755432Ab0JVMtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Oct 2010 08:49:23 -0400
Content-Disposition: inline
In-Reply-To: <20101021171532.54af5e97@xenia.leun.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 21, 2010 at 05:15:32PM +0200, Michael Leun wrote:
> unfortunately the bug described below originally reported in 2.6.35-rcX
> is still there in 2.6.36.

can you post your full kernel .config?

I'm using network namespaces quite extensively - OpenVPN and IPv6
included - and i haven't hit this bug. That makes it rather likely it
depends on some option difference.

btw, while the bridging bug is unrelated, it might be the same kind of
origin - a skb not being free'd. can you leave the namespace running for
a few minutes and check whether the usage count number is higher then?


-David

