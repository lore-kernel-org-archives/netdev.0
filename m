From: "David S. Miller" <davem@redhat.com>
Subject: Re: Initialising net/ipv4/ before net/ipv6/ breaks IPv6 autoconf
 with nfsroot....
Date: Thu, 19 Feb 2004 22:22:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219222253.082458cf.davem@redhat.com>
References: <1077201499.18703.381.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1077201499.18703.381.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Feb 2004 14:38:20 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> Putting IPv6 before IPv4 in net/Makefile fixes it, letting it IPv6
> register its notifiers before the IPv4 ipconfig code brings up the
> interface.
> 
> Objections?

No objection.  Send me a patch.

If at some point we create some initialization dependency between ipv4
and ipv6 (f.e. ipv6 init needs some ipv4 table setup) we will need to
tread carefully to keep this from breaking.

I did a quick audit and no such dependency exists now, so we can put in
the change without breaking anything.
