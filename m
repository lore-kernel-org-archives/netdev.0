From: "David S. Miller" <davem@redhat.com>
Subject: Re: Initialising net/ipv4/ before net/ipv6/ breaks IPv6 autoconf
 with nfsroot....
Date: Fri, 20 Feb 2004 11:07:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040220110717.4c8e9f59.davem@redhat.com>
References: <1077201499.18703.381.camel@hades.cambridge.redhat.com>
	<20040219222253.082458cf.davem@redhat.com>
	<1077303696.427.570.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1077303696.427.570.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 Feb 2004 19:01:37 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> On Thu, 2004-02-19 at 22:22 -0800, David S. Miller wrote:
> > If at some point we create some initialization dependency between ipv4
> > and ipv6 (f.e. ipv6 init needs some ipv4 table setup) we will need to
> > tread carefully to keep this from breaking.
> 
> True. For 2.6 in fact we can do it this way...

I like this version of this fix a lot, applied.
