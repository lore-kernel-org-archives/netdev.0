From: Joe Perches <joe@perches.com>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Mon, 30 Aug 2010 21:03:03 -0700
Message-ID: <1283227383.1759.33.camel@Joe-Laptop>
References: <20100706142542.d723903f.sfr@canb.auug.org.au>
	 <20100831125738.7f18610b.sfr@canb.auug.org.au>
	 <1283224474.1759.30.camel@Joe-Laptop>
	 <20100831135831.b0f124c4.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>,
	James Bottomley <James.Bottomley@suse.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100831135831.b0f124c4.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-08-31 at 13:58 +1000, Stephen Rothwell wrote:
> On Mon, 30 Aug 2010 20:14:34 -0700 Joe Perches <joe@perches.com> wrote:
> > On Tue, 2010-08-31 at 12:57 +1000, Stephen Rothwell wrote:
> > > On Tue, 6 Jul 2010 14:25:42 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > > > After merging the net tree, today's linux-next build (powerpc
> > > > ppc64_defconfig) produced these warnings:
> > > > drivers/scsi/sym53c8xx_2/sym_hipd.c: In function 'sym_print_msg':
> > []
> > > > Introduced by commit 99bcf217183e02ebae46373896fba7f12d588001 ("device.h
> > > > drivers/base/core.c Convert dev_<level> logging macros to functions").
> > > Can we have a fix for these please?  They make too much noise in the builds.
> > Submitted July 7
> > https://patchwork.kernel.org/patch/111271/
> Yes, but there were comments on that and nothing since.  I think that
> James would like a minimal patch that just fixes the newly introduced
> warnings.

Hi Stephen.

What I submitted I think reasonable.
He can extract what he wants if he prefers it done that way.

cheers, Joe
