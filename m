From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [ANN] removal of certain net drivers coming soon: eepro100, xircom_tulip_cb, iph5526
Date: Fri, 28 Jan 2005 01:48:25 +0100
Message-ID: <20050128004825.GA5359@xi.wantstofly.org>
References: <41F952F4.7040804@pobox.com> <20050127225725.F3036@flint.arm.linux.org.uk> <20050127153114.72be03e2.davem@davemloft.net> <20050128001430.C22695@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, greg@kroah.com,
        akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20050128001430.C22695@flint.arm.linux.org.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 28, 2005 at 12:14:30AM +0000, Russell King wrote:

> The fact of the matter is that eepro100.c works on ARM, e100.c doesn't.

Hmmm, I recall e100 working fine on a Radisys ENP-2611, which has a
IXP2400 (xscale) in big-endian mode, running 2.6.  This particular
board had its root fs NFS-mounted and pumped several hundreds of
gigabytes through the NIC during a period of at least a few months,
and I never saw any problems.

Something tells me that the next time I try it, it won't work at all.


--L
