From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Fri, 21 Sep 2007 11:42:07 -0700
Message-ID: <20070921114207.f0b54b3b.akpm@linux-foundation.org>
References: <Pine.LNX.4.64N.0709171750220.17606@blysk.ds.pg.gda.pl>
	<20070920165348.0b25be3d.akpm@linux-foundation.org>
	<Pine.LNX.4.64N.0709211334420.2724@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47812 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761243AbXIUSmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 14:42:50 -0400
In-Reply-To: <Pine.LNX.4.64N.0709211334420.2724@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Sep 2007 13:51:12 +0100 (BST)
"Maciej W. Rozycki" <macro@linux-mips.org> wrote:

> On Thu, 20 Sep 2007, Andrew Morton wrote:
> 
> > You always put boring, crappy, insufficient text in the for-the-changelog
> > section and interesting, useful, sufficient text in the not-for-the-changelog
> > section.
> 
>  I'll swap the sections in the future then. ;-)  Frankly I was not sure 
> whether the changelog was happy about being fed with lengthy explanations 
> and it has not spoken out.

I think it's worth putting plenty of details in the changelog: it's compressed
on-disk and on-the-wire and is overall pretty cheap.  If people don't
actually seek the information out, it has close to zero impact on them.

But on those occasions when people _do_ seek the information out (and it
can be years later) then they want every drop of information they can get.

Numerous times I've gone back to the 2.5.x mm/ changelogs to work out
what on earth we were thinking when we did something, and it has proved
quite useful in explaining the existing code, or in suggesting possible
problems which we had forgotten about by 2007.


otoh, you can get a lot of handy info by googling for strategic parts of
the kernel code, or by googling snippets of the existing-but-short
changelog.  For example, this patch: google for "Keep track of
disable_irq_nosync() invocations" and voila.  Perhaps we don't need
changelogs at all ;)

