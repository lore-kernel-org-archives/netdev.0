From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fragmentation Attack
Date: Sun, 8 Feb 2004 12:45:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040208124528.2c667378.davem@redhat.com>
References: <20040207094524.495e883d.davem@redhat.com>
	<BC4A83EB.E263%gandalf@digital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gandalf The White <gandalf@digital.net>
In-Reply-To: <BC4A83EB.E263%gandalf@digital.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 07 Feb 2004 12:00:42 -0600
Gandalf The White <gandalf@digital.net> wrote:

> The requirements of the attack (from the perspective of the paper I wrote)
> was that you had taken over 20 cable modem computers.  From this viewpoint
> this could (of course) produce the required number of packets IMHO.
>
> Of course you could also clog up the bandwidth of just about any destination
> network with this requirement, but that is a different DoS.

Yes, but this very fact makes the "DoS" much much less interesting.
If I can clog your link anyways with arbitrary traffic, who cares
what it does as a second order effect, the machine is made unreachable
and unusable either way.

Also, these half-complete ICMP packets are really super easy to create
firewall rules for to block them at ingress of a major site.
