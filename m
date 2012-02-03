From: Guillaume Chazarain <guichaz@gmail.com>
Subject: Re: Sudden kernel panic with skge in 3.3-rc2
Date: Fri, 3 Feb 2012 23:05:26 +0100
Message-ID: <CAA879TM1i7prdY_=o2NYPYd5U2NuyyvMstT-qFoF1===qfQekA@mail.gmail.com>
References: <20120202192115.GA8480@elliptictech.com>
	<20120202124529.3e274223@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nick Bowler <nbowler@elliptictech.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120202124529.3e274223@s6510.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 2, 2012 at 9:45 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> Try reverting this commit, it seems problematic
> commit d0249e44432aa0ffcf710b64449b8eaa3722547e

Reverting this commit fixed skge for me. The NIC stopped working after
a kernel upgrade with nothing interesting in dmesg:

skge: 1.14 addr 0xfbffc000 irq 18 chip Yukon-Lite rev 9
skge 0000:03:00.0: eth0: addr 00:15:f2:46:d3:3b
skge 0000:03:00.0: eth0: enabling interface
ADDRCONF(NETDEV_UP): eth0: link is not ready
skge 0000:03:00.0: eth0: Link is up at 100 Mbps, full duplex, flow control both
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present

NetworkManager would Oops during shutting down: http://i.imgur.com/eAFgM.jpg

-- 
Guillaume
