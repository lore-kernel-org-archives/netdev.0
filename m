From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [PATCH 1/6] Convert bonding timers to workqueues
Date: Mon, 22 Oct 2007 10:55:17 -0400
Message-ID: <170fa0d20710220755w744e8ec8w1d85cae4f4be822e@mail.gmail.com>
References: <11920760494096-git-send-email-fubar@us.ibm.com>
	 <11920760502756-git-send-email-fubar@us.ibm.com>
	 <4713B44E.7030902@pobox.com> <20038.1192475339@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jay Vosburgh" <fubar@us.ibm.com>, netdev@vger.kernel.org,
	andy@greyhouse.net
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.238]:2141 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbXJVOzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 10:55:18 -0400
Received: by nz-out-0506.google.com with SMTP id s18so442999nze
        for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 07:55:18 -0700 (PDT)
In-Reply-To: <20038.1192475339@death>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/15/07, Jay Vosburgh <fubar@us.ibm.com> wrote:
> Jeff Garzik <jgarzik@pobox.com> wrote:
>
> >Jay Vosburgh wrote:
> >>      Convert bonding timers to workqueues.  This converts the various
> >> monitor functions to run in periodic work queues instead of timers.  This
> >> patch introduces the framework and convers the calls, but does not resolve
> >> various locking issues, and does not stand alone.
> >>
> >> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> >> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> >
> >"does not stand alone" == it is not bisectable?  That's a problem.
>
>         The patch will compile fine (this is true for any point in the
> series), but it's possible for bonding to deadlock or misbehave when
> doing certain operations.  Those problems are addressed in the later
> patches.
>
>         I didn't want to just vomit out one big mega-patch that has the
> whole set of changes, because that's harder to understand, and the later
> patches generally address discrete issues.
>
>         Does that make you more or less nervous about its bisectability?
> I can repost the whole thing as a big blob if that's what you'd prefer.
>
> >Anyway, we have more fun fish to fry:  after applying the IPoIB bonding
> >patchset, this no longer applies...
>
>         Yah, I'll rebase it (once I know your blob vs. not-blob
> preference).  I wasn't sure how long the IPoIB mystery bug hunt was
> going to take.

Jeff,

Given that Jay rebased and posted updated bonding locking patches on
Oct 17 will you be pushing them for inclusion in 2.6.24-rc1?  or
2.6.24-rcX?  I don't see them queued in your netdev-2.6 tree.  These
bonding locking issues have been a problem for some time and it would
be very good to get them fixed upstream sooner rather than later.

thanks,
Mike
