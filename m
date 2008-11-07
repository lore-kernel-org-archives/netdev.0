From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Fri, 7 Nov 2008 20:28:10 +0300
Message-ID: <20081107172810.GB15239@ioremap.net>
References: <1225450706.5301.94.camel@localhost> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com> <1225838743.6116.20.camel@fry> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com> <20081106080316.GA32337@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com> <20081106194032.GB31673@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:57860 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750879AbYKGR2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 12:28:11 -0500
Content-Disposition: inline
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 06, 2008 at 11:53:35AM -0800, Lovich, Vitali (vlovich@qualcomm.com) wrote:
> Are there any consequences to bypassing qdisc (other than not participating in any load balancing)?  Also, since any users using the tx ring approach would have to write new code, it would be part of the documentation that the send behaviour is optimized for the least latency and highest throughput, thus no guarantees and assumptions can be made about the path the data takes through the stack.

qdisc is a base for multiqueue NICs (and all others too now), you can not bypass it there.

-- 
	Evgeniy Polyakov
