From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH -mm] __ratelimit rewrite
Date: Sun, 04 May 2008 19:52:54 -0700
Message-ID: <1209955974.13011.10.camel@localhost>
References: <20080504070738.GA11832@darkstar.te-china.tietoenator.com>
	 <1209912447.16966.42.camel@localhost>
	 <a8e1da0805041837q4a5264c6l7bc23dce1d3282fd@mail.gmail.com>
	 <1209954305.13011.1.camel@localhost>
	 <a8e1da0805041958k30c03e20r6dd88f4135d6e5fe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, paulmck@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:3142 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750989AbYEEDTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 23:19:09 -0400
In-Reply-To: <a8e1da0805041958k30c03e20r6dd88f4135d6e5fe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-05-05 at 10:58 +0800, Dave Young wrote:
> On Mon, May 5, 2008 at 10:25 AM, Joe Perches <joe@perches.com> wrote:
> > On Mon, 2008-05-05 at 09:37 +0800, Dave Young wrote:
> >  > >  I think your changes should then be done in
> >  > >  printk.h not creating a new ratelimit.h.
> >  > IMO ratelimit is not just for printk use now, so a standalone head
> >  > file is necessary.
> >  What other uses would ratelimit have?
> ratelimit is a general function,  another user of it is
> WARN_ON_RATELIMIT in this patch. It could have other usage in future.

You put WARN_ON_RATELIMIT in bug.h right?
WARN_ON in bug.h is a printk

printk.h should #include <asm/bug.h>
kernel.h should not include that file.

What non print related function could be served by ratelimit?



