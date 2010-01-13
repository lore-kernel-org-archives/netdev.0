From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Makefile: Document ability to make file.lst and file.S
Date: Wed, 13 Jan 2010 18:14:11 +0100
Message-ID: <20100113171411.GC24818@basil.fritz.box>
References: <4B49D001.4000302@gmail.com> <4B4DA4F4.6060007@gmail.com> <20100113115617.GA24818@basil.fritz.box> <4B4DE887.6030602@gmail.com> <20100113155323.GB24818@basil.fritz.box> <1263400835.8011.73.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Michal Marek <mmarek@suse.cz>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kbuild@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1263400835.8011.73.camel@Joe-Laptop.home>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2010 at 08:40:35AM -0800, Joe Perches wrote:
> On Wed, 2010-01-13 at 16:53 +0100, Andi Kleen wrote:
> > On Wed, Jan 13, 2010 at 10:36:39AM -0500, William Allen Simpson wrote:
> > > What make command would you suggest to get the interleaved asm?
> > make path/to/file.lst
> > (or .S -- you might need uptodate binutils if the lst listing is messed up)
> 
> I didn't know that was possible.

The trap is that it doesn't work well on most systems with too 
old binutils (unless the gcc is really ancient)

-Andi
