From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: Re: [Devel] Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Wed, 17 Jun 2009 09:49:07 +0900
Message-ID: <20090617094907.e8cd77bd.usui@mxm.nes.nec.co.jp>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
	<20090611.021347.142243970.davem@davemloft.net>
	<20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp>
	<6599ad830906112206n745fb0dw19cdb75d7c40b2a4@mail.gmail.com>
	<20090615120035.a8b7b38f.usui@mxm.nes.nec.co.jp>
	<20090615101919.GC7768@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul Menage <menage@google.com>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	hadi@cyberus.ca, jarkao2@gmail.com
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:33909 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbZFQC4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 22:56:21 -0400
In-Reply-To: <20090615101919.GC7768@bombadil.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Jun 2009 06:19:19 -0400
Thomas Graf <tgraf@infradead.org> wrote:

> On Mon, Jun 15, 2009 at 12:00:35PM +0900, Minoru Usui wrote:
> > Actually, In tc <-> kernel I/F (which uses netlink), tc sets classid to hexadecimal style not X:Y style.
> > X:Y style is result of translating by tc command.
> > 
> > I thought this patch was very useful at first, but it's not necessary to implementing to the kernel.
> > This function can be implemented on user space if we need.
> > And we can also keep compatibility of net_cls.classid I/F. :-)
> > 
> > I drop this patch. I'm sorry for confusing a lot of people.
> 
> I found this patch to be extremely useful if it wasn't to break
> compatibility but that issue can be resolved by accepting both
> formats easly.

Thank you for agreeing my patch.

I think you said write format only. Am I right?
What do you think about read format?
Do you think you should keep read format as current implementation?

I think we should need to unify read/write format, if we make cls_cgroup is more userfriendly. 
Because some of people are confused about having to read their write value as different format.
(Unfortunately, current implementation is so...)

But this approach breaks compatibility, so I drop this patch.
-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
