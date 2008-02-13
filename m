From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: BUG: 2.6.25-rc1: iptables postrouting setup causes oops
Date: Wed, 13 Feb 2008 01:22:31 -0800
Message-ID: <20080213012231.46865608.akpm@linux-foundation.org>
References: <1202816761.3299.19.camel@moss.renham>
	<20080213004829.fd8afdc7.akpm@linux-foundation.org>
	<20080213101024.39347322@dhcp-252-066.norway.atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Nizette <bn@niasdigital.com>, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morgan <morgan@kernel.org>
To: Haavard Skinnemoen <hskinnemoen@atmel.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080213101024.39347322@dhcp-252-066.norway.atmel.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Feb 2008 10:10:24 +0100 Haavard Skinnemoen <hskinnemoen@atmel.com> wrote:

> On Wed, 13 Feb 2008 00:48:29 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Tue, 12 Feb 2008 22:46:01 +1100 Ben Nizette <bn@niasdigital.com> wrote:
> > 
> > > 
> > > On an AVR32, root over NFS, config attached, running (from a startup
> > > script):
> > > 
> > > iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
> > > 
> > > Results in (dmesg extract including a bit of context for good measure):
> > > -------------8<----------------
> > > VFS: Mounted root (nfs filesystem).
> > > Freeing init memory: 72K (90000000 - 90012000)
> > > eth0: no IPv6 routers present
> > > warning: `dnsmasq' uses 32-bit capabilities (legacy support in use)
> 
> Hmm. What does that mean? What size do capabilities normally have?

My near-namesake put than in, but I immediately forgot what it means?
