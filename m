From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Mon, 30 Aug 2010 21:46:43 -0700 (PDT)
Message-ID: <20100830.214643.214234410.davem@davemloft.net>
References: <1283224474.1759.30.camel@Joe-Laptop>
	<20100831135831.b0f124c4.sfr@canb.auug.org.au>
	<1283227383.1759.33.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@suse.de, James.Bottomley@suse.de
To: joe@perches.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1283227383.1759.33.camel@Joe-Laptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 30 Aug 2010 21:03:03 -0700

> On Tue, 2010-08-31 at 13:58 +1000, Stephen Rothwell wrote:
>> On Mon, 30 Aug 2010 20:14:34 -0700 Joe Perches <joe@perches.com> wrote:
>> > On Tue, 2010-08-31 at 12:57 +1000, Stephen Rothwell wrote:
>> > > On Tue, 6 Jul 2010 14:25:42 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>> > > > After merging the net tree, today's linux-next build (powerpc
>> > > > ppc64_defconfig) produced these warnings:
>> > > > drivers/scsi/sym53c8xx_2/sym_hipd.c: In function 'sym_print_msg':
>> > []
>> > > > Introduced by commit 99bcf217183e02ebae46373896fba7f12d588001 ("device.h
>> > > > drivers/base/core.c Convert dev_<level> logging macros to functions").
>> > > Can we have a fix for these please?  They make too much noise in the builds.
>> > Submitted July 7
>> > https://patchwork.kernel.org/patch/111271/
>> Yes, but there were comments on that and nothing since.  I think that
>> James would like a minimal patch that just fixes the newly introduced
>> warnings.
> 
> Hi Stephen.
> 
> What I submitted I think reasonable.

Me too.

> He can extract what he wants if he prefers it done that way.

Exactly, he's the maintainter so if he wants something fixed a
specific way he can do it as he likes.
