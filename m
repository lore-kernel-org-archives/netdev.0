From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [Devel] Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Mon, 15 Jun 2009 06:19:19 -0400
Message-ID: <20090615101919.GC7768@bombadil.infradead.org>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp> <20090611.021347.142243970.davem@davemloft.net> <20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp> <6599ad830906112206n745fb0dw19cdb75d7c40b2a4@mail.gmail.com> <20090615120035.a8b7b38f.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Menage <menage@google.com>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	hadi@cyberus.ca, jarkao2@gmail.com
To: Minoru Usui <usui@mxm.nes.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49664 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753542AbZFOKTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 06:19:24 -0400
Content-Disposition: inline
In-Reply-To: <20090615120035.a8b7b38f.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2009 at 12:00:35PM +0900, Minoru Usui wrote:
> Actually, In tc <-> kernel I/F (which uses netlink), tc sets classid to hexadecimal style not X:Y style.
> X:Y style is result of translating by tc command.
> 
> I thought this patch was very useful at first, but it's not necessary to implementing to the kernel.
> This function can be implemented on user space if we need.
> And we can also keep compatibility of net_cls.classid I/F. :-)
> 
> I drop this patch. I'm sorry for confusing a lot of people.

I found this patch to be extremely useful if it wasn't to break
compatibility but that issue can be resolved by accepting both
formats easly.

A classid is in a fact a set of two 16 bit integers and everyone
is used to the X:Y notation. procfs and sysfs ought to be userfriendly
to a certain degree and adding such a small parser to cls_cgroup
doesn't harm anyone.
