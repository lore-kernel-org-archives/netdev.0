From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: Tree for Mar 9 (netfilter)
Date: Sun, 11 Mar 2012 16:52:41 +0100
Message-ID: <20120311155241.GA27058@1984>
References: <giupeu1.ee21a87813f836d9f587ea0b0e19a695@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Hans Schillstrom <hans@schillstrom.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <giupeu1.ee21a87813f836d9f587ea0b0e19a695@obelix.schillstrom.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hans,

On Sun, Mar 11, 2012 at 01:37:25PM +0100, Hans Schillstrom wrote:
> Hello
> >On Fri, Mar 09, 2012 at 12:30:42PM -0800, Randy Dunlap wrote:
> >> On 03/09/2012 12:11 AM, Stephen Rothwell wrote:
> >>
> >> > Hi all,
> >> >
> >> > There will be no linux-next release on March 12 due to a public holiday.
> >> >
> >> > Changes since 20120308:
> >>
> >>
> >> xt_LOG.c:(.text+0x789b1): undefined reference to `ip6t_ext_hdr'
> >>
> >> Full randconfig file is attached.
> >
> >The patch attached fixes this problem, thanks!
> 
> 
> This one is needed as well,
> 
> To force xt_LOG  to be configured as a module if ipv6 is a module,
> otherwise you end up in the same linking problem

Perhaps I'm missing anything but either way (IPv6 as module or
built-in) the symbol is still defined. With my patch applied, xt_LOG
now depends on IP6_NF_IPTABLES, which depends on IPV6.

Moreover we've got other xt_ target and matches that contain both IPv4
and IPv6 support that don't require this.

Let me know.
