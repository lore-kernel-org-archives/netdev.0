From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fix incorrect original ingress device index in
 PKTINFO
Date: Thu, 29 Dec 2016 14:08:27 -0500 (EST)
Message-ID: <20161229.140827.902854827832353748.davem@davemloft.net>
References: <1483001104-17614-1-git-send-email-asuka.com@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: asuka.com@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483001104-17614-1-git-send-email-asuka.com@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Zhang <asuka.com@163.com>
Date: Thu, 29 Dec 2016 16:45:04 +0800

> When we send a packet for our own local address on a non-loopback
> interface (e.g. eth0), due to the change had been introduced from
> commit 0b922b7a829c ("net: original ingress device index in PKTINFO"), the
> original ingress device index would be set as the loopback interface.
> However, the packet should be considered as if it is being arrived via the
> sending interface (eth0), otherwise it would break the expectation of the
> userspace application (e.g. the DHCPRELEASE message from dhcp_release
> binary would be ignored by the dnsmasq daemon, since it come from lo which
> is not the interface dnsmasq bind to)
> 
> Fixes: 0b922b7a829c ("net: original ingress device index in PKTINFO")
> Acked-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Wei Zhang <asuka.com@163.com>

Applied and queued up for -stable.
