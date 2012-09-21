From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] ipconfig: add nameserver IPs to kernel-parameter ip=
Date: Fri, 21 Sep 2012 14:51:44 -0400 (EDT)
Message-ID: <20120921.145144.14955032475453606.davem@davemloft.net>
References: <1348177730.3858.98.camel@mars>
	<20120921.133759.1667263015470766968.davem@davemloft.net>
	<1348252279.12456.2.camel@mars>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rob@landley.net, kuznet@ms2.inr.ac.ru, j.weitzel@phytec.de,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, hjk@hansjkoch.de, daniel@zonque.org
To: chf.fritz@googlemail.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1348252279.12456.2.camel@mars>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Fritz <chf.fritz@googlemail.com>
Date: Fri, 21 Sep 2012 20:31:19 +0200

> On small systems (e.g. embedded ones) IP addresses are often configured
> by bootloaders and get assigned to kernel via parameter "ip=".  If set to
> "ip=dhcp", even nameserver entries from DHCP daemons are handled. These
> entries exported in /proc/net/pnp are commonly linked by /etc/resolv.conf.
> 
> To configure nameservers for networks without DHCP, this patch adds option
> <dns0-ip> and <dns1-ip> to kernel-parameter 'ip='.
> 
> Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
> Tested-by: Jan Weitzel <j.weitzel@phytec.de>

Applied to net-next, thanks.
