From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2.6] (1/3) add ethtool ioctl forwarding to vlan
Date: Tue, 03 Aug 2004 11:02:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <410FD348.9040301@candelatech.com>
References: <20040803105017.0774e1db@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040803105017.0774e1db@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> When network devices are used in bridges, the bridge does an ethtool
> ioctl to pick up the speed; this doesn't work with vlans.
> This patch makes any ethtool gets forwarded to the under lying
> real device.  It seemed to make sense to do MII as well.

Looks good to me.  I'll also send a patch against 2.6.8 (when it's out)
to bring the 2.6 VLAN code up to date with the latest 2.4 stuff.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
