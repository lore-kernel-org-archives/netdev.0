From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Thu, 28 Feb 2008 13:30:08 -0800 (PST)
Message-ID: <20080228.133008.228590007.davem@davemloft.net>
References: <20080228014125.GI3078@tuxdriver.com>
	<20080227.235110.242439399.davem@davemloft.net>
	<97a0a9ac0802281321h6f302865j38a55c6f761dc14b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: gordonfarquharson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47044
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764743AbYB1VaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 16:30:09 -0500
In-Reply-To: <97a0a9ac0802281321h6f302865j38a55c6f761dc14b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gordon Farquharson" <gordonfarquharson@gmail.com>
Date: Thu, 28 Feb 2008 14:21:21 -0700

> Hi David
> 
> On Thu, Feb 28, 2008 at 12:51 AM, David Miller <davem@davemloft.net> wrote:
> > From: "John W. Linville" <linville@tuxdriver.com>
> >  Date: Wed, 27 Feb 2008 20:41:25 -0500
> >
> >
> >  > Gordon Farquharson (1):
> >  >       Fix b43 driver build for arm
> >
> >  Please revert this change and resend your pull request.
> >
> >  If file2alias doesn't work properly in a cross build environment, we
> >  don't fix it by crapping up mod_devalias.h with these silly align
> >  attribute annotations.
> 
> This was extensively discussed on LKML [1, 2] and the patch has been
> merged into Andrew Morton's -mm tree. It is understood that this is
> not the Right Way to fix to problem, hence the big fat comment in the
> code. It would be great if you could reconsider your decision.

If you put that thing in there now, on ARM the structure size changes
as does the alignment of that final member.

Then we're stuck with it and you can't remove that hack from
mod_devalias.h.  It can't be removed even after the cross build issues
of file2alias are resolved properly without re-breaking ARM.

Feel free to push that via Andrew or someone else, but that turd isn't
going in by my tree because to me it's clearly the wrong thing to do.
