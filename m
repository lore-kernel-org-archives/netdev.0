From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 3x59x-fix-pci-resource-management.patch
Date: Fri, 7 Aug 2009 01:33:10 -0700
Message-ID: <20090807013310.0cb4e51f.akpm@linux-foundation.org>
References: <20090806154223.b9b9759e.akpm@linux-foundation.org>
	<20090807081928.GA12932@skl-net.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, netdev@vger.kernel.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45865 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757093AbZHGIdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 04:33:46 -0400
In-Reply-To: <20090807081928.GA12932@skl-net.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Aug 2009 10:19:28 +0200 Steffen Klassert <klassert@mathematik.tu-chemnitz.de> wrote:

> On Thu, Aug 06, 2009 at 03:42:23PM -0700, Andrew Morton wrote:
> > 
> > Guys, I seem to have been sitting on the below patch for, err, three years.
> > 
> > I generally do this because there's some issue which needs to be
> > addressed, but the patch didn't address it right.
> > 
> > Can we please have a revisit and work out what we should do with this?
> > 
> 
> I don't know the story from the beginning.

I've forgotten.  I don't recall seeing any bug reports which this patch
might fix.

> Are there any issues with
> this patch aside the compile error that was caused if CONFIG_PCI is not
> enabled? The compile error should be fixed and the rest looks ok on the
> first view.

I just did a PCI=n, EISA=y build and it compiled OK.

