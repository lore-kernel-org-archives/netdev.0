From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: unregister_netdevice: waiting for tun6to4 to become free.
Date: Mon, 20 Sep 2004 20:59:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414F7CD9.3090008@pobox.com>
References: <20040920212453.GA15392@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20040920212453.GA15392@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pekka Pietikainen wrote:
> Hiya
> 
> When trying to do /etc/init.d/network stop (or reboot) my
> fc3test-all-updated-so-kernel-is-2.6.9-rc2-bk5ish, the thing hangs with a
> "unregister_netdevice: waiting for tun6to4 to become free. Usage count = 1".
> The 6to4 tunnel is over the kernel PPPoE tunnel in case that makes a
> difference


I hit this _once_ on my gateway (NAT'ing firewall IPv4, now also IPv6 
router).

No idea why it went away, I just assumed a more recent kernel fixed 
something.

	Jeff
