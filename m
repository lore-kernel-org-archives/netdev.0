From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] tcp: setsockopt congestion control autoload
Date: Thu, 26 Oct 2006 19:05:03 +0200
Message-ID: <4540EABF.9020207@trash.net>
References: <20061025110843.0cbd18a7@freekitty>	<20061026052253.GA10188@2ka.mipt.ru>	<4540C791.5060200@osdl.org>	<20061026145712.GA11062@2ka.mipt.ru> <20061026082314.1dcea52c@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44719 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1161435AbWJZRFH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 13:05:07 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061026082314.1dcea52c@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> No capability check needed. Any additional paranoia belongs in /sbin/modprobe.
> 
> There seems to be lots of existing usage where a user can cause a module
> to be loaded (see bin_fmt, xtables, etc).


x_tables is restricted to CAP_NET_ADMIN, but in net/ alone we have
__sock_create (loads protocol families), sock_ioctl (loads bridge,
vlan or dlci), the already mentioned netlink case, inet_create
(loads IP protocols), inet6_create (similar to inet_create), and
a few more.

