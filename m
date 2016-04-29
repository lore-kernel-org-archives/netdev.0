From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 2/2] ppp: add rtnetlink device creation
 support
Date: Fri, 29 Apr 2016 16:10:11 -0400 (EDT)
Message-ID: <20160429.161011.1162718802493722811.davem@davemloft.net>
References: <cover.1461854990.git.g.nault@alphalink.fr>
	<20160428155530.GA24359@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	paulus@samba.org, stephen@networkplumber.org, wharms@bfs.de
To: g.nault@alphalink.fr
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20160428155530.GA24359@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 28 Apr 2016 17:55:30 +0200

> Define PPP device handler for use with rtnetlink.
> The only PPP specific attribute is IFLA_PPP_DEV_FD. It is mandatory and
> contains the file descriptor of the associated /dev/ppp instance (the
> file descriptor which would have been used for ioctl(PPPIOCNEWUNIT) in
> the ioctl-based API). The PPP device is removed when this file
> descriptor is released (same behaviour as with ioctl based PPP
> devices).
> 
> PPP devices created with the rtnetlink API behave like the ones created
> with ioctl(PPPIOCNEWUNIT). In particular existing ioctls work the same
> way, no matter how the PPP device was created.
> The rtnl callbacks are also assigned to ioctl based PPP devices. This
> way, rtnl messages have the same effect on any PPP devices.
> The immediate effect is that all PPP devices, even ioctl-based
> ones, can now be removed with "ip link del".
> 
> A minor difference still exists between ioctl and rtnl based PPP
> interfaces: in the device name, the number following the "ppp" prefix
> corresponds to the PPP unit number for ioctl based devices, while it is
> just an unrelated incrementing index for rtnl ones.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Series applied, thanks for doing this work!
