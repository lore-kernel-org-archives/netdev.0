From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vortex_up should initialize "err"
Date: Wed, 17 Oct 2007 23:58:19 -0700
Message-ID: <20071017235819.25bf1d5d.akpm@linux-foundation.org>
References: <1192662956.14504.14.camel@dyn9047017100.beaverton.ibm.com>
	<4716A8B4.5060406@garzik.org>
	<20071018060506.GA30544@newton.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Badari Pulavarty <pbadari@us.ibm.com>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, satyam@infradead.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39513 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932514AbXJRHog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 03:44:36 -0400
In-Reply-To: <20071018060506.GA30544@newton.mathematik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Oct 2007 08:05:06 +0200 Steffen Klassert <klassert@mathematik.tu-chemnitz.de> wrote:

> On Wed, Oct 17, 2007 at 08:28:36PM -0400, Jeff Garzik wrote:
> > Badari Pulavarty wrote:
> > >Simple compile warning fix. (against 2.6.23-git12)
> > >
> > >Thanks,
> > >Badari
> > >
> > >vortex_up() should initialize 'err' for a successful return.
> > >
> > >drivers/net/3c59x.c: In function `vortex_up':
> > >drivers/net/3c59x.c:1494: warning: `err' might be used uninitialized in 
> > >this function
> > 
> > applied as an obvious bug fix (Steffen added to CC)
> > 
> 
> Hm, we had already the 3c59x-fix-uninitialized-variable-bug.patch from
> Satyam Sharma in -mm to fix this, but the patch was removed from -mm
> some time ago. Andrew, what happened to this one?

It's fixed in Jeff's netdev tree.
