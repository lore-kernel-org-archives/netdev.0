From: David Woodhouse <dwmw2@redhat.com>
Subject: Re: Missing routes cause BUG() in icmpv6_xmit_lock().
Date: Mon, 01 Sep 2003 10:58:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1062410301.9518.19.camel@hades.cambridge.redhat.com>
References: <1062341789.2785.11.camel@imladris.demon.co.uk>
	 <20030831224454.349a6a53.davem@redhat.com>
	 <20030901013020.189fe564.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030901013020.189fe564.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-09-01 at 01:30 -0700, David S. Miller wrote:
> On Sun, 31 Aug 2003 22:44:54 -0700
> "David S. Miller" <davem@redhat.com> wrote:
> 
> > I'll see what I can do about this one.
> 
> Ok, here is the fix I'm going to use.  I actually inadvertantly
> added this problem when I converted net/ipv6/icmp.c over to
> per-cpu sockets.

In the meantime, since there's nothing to prevent anyone from faking
ICMP6 echo packets from an 'internal' machine and sending them to a
victim over the IPv4 encap, it might be prudent for everyone doing 6to4
to add an unreachable route to their 2002:XXXX:YYYY::/48 subnet, which
seems to avoid the problem.

-- 
dwmw2
