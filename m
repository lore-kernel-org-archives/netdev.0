From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH] vortex_up should initialize "err"
Date: Thu, 18 Oct 2007 08:05:06 +0200
Message-ID: <20071018060506.GA30544@newton.mathematik.tu-chemnitz.de>
References: <1192662956.14504.14.camel@dyn9047017100.beaverton.ibm.com> <4716A8B4.5060406@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badari Pulavarty <pbadari@us.ibm.com>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, satyam@infradead.org
To: Jeff Garzik <jeff@garzik.org>, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from john.hrz.tu-chemnitz.de ([134.109.132.2]:54209 "EHLO
	john.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753730AbXJRGFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 02:05:11 -0400
Content-Disposition: inline
In-Reply-To: <4716A8B4.5060406@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2007 at 08:28:36PM -0400, Jeff Garzik wrote:
> Badari Pulavarty wrote:
> >Simple compile warning fix. (against 2.6.23-git12)
> >
> >Thanks,
> >Badari
> >
> >vortex_up() should initialize 'err' for a successful return.
> >
> >drivers/net/3c59x.c: In function `vortex_up':
> >drivers/net/3c59x.c:1494: warning: `err' might be used uninitialized in 
> >this function
> 
> applied as an obvious bug fix (Steffen added to CC)
> 

Hm, we had already the 3c59x-fix-uninitialized-variable-bug.patch from
Satyam Sharma in -mm to fix this, but the patch was removed from -mm
some time ago. Andrew, what happened to this one?

However, this issue should be fixed.

Thanks,

Steffen
