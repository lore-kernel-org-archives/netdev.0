From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Bug 4554] New: /proc/net/route missing info for 127.0.0.1/8
Date: Wed, 04 May 2005 00:41:01 +0200
Message-ID: <4277FDFD.3040501@trash.net>
References: <20050503143603.4d77d3dd@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050503143603.4d77d3dd@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Distribution: CentOS 4 (RHEL4)
> Hardware Environment: i686
> Problem Description:
> cat /proc/net/route is missing information for 127.0.0.1/8 network (lo
> interface).  On 2.4 kernels, this info was present (just checked on an old RH7.3
> machine).  It seems to be missing on 2.6 kernels.  Bug?  Feature?  Omission?

2.4.30 doesn't show it:

# route -n
Destination     Gateway         Genmask         Flags Metric Ref    Use
Iface
172.16.0.0      0.0.0.0         255.255.0.0     U     0      0        0 eth0

And I'd be surprised if it did, it doesn't include other routes
from the local table.

Regards
Patrick
