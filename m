From: "Michael Bommarito" <michael.bommarito@gmail.com>
Subject: Re: [PATCH 2.6.19-git19] BUG due to bad argument to ieee80211softmac_assoc_work
Date: Thu, 14 Dec 2006 16:48:48 -0500
Message-ID: <5b8e20700612141348l66af58b6lb6899b710d1d9c14@mail.gmail.com>
References: <5b8e20700612131017n1cd8aff3qbe41351435427e25@mail.gmail.com>
	 <341A1CE8-DF10-4CD5-B675-89449256EAB5@deine-taler.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:58006 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932938AbWLNVsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 16:48:50 -0500
Received: by ug-out-1314.google.com with SMTP id 44so629415uga
        for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 13:48:49 -0800 (PST)
To: "Uli Kunitz" <kune@deine-taler.de>
In-Reply-To: <341A1CE8-DF10-4CD5-B675-89449256EAB5@deine-taler.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Uli,
  Yes, apologies, I had been waiting for an abandoned bugzilla entry
to get attention, and when I realized it was assigned to a dead-end, I
had simply posted the patch without checking for prior messages.
  I was further confused by the fact that it hadn't made its way into
any of the 19-gitX sets (and for that matter, the window for
2.6.20-rc1 has come and gone and this still remains unfixed), despite
how clear the error was and how trivial the fix seems.

-Mike

On 12/14/06, Uli Kunitz <kune@deine-taler.de> wrote:
> Michael,
>
> I sent a patch to this list on Sunday, that patched the problem. It
> seems to be migrated into the wireless-2.6 git tree.
>
> Regards,
>
> Uli
> Am 13.12.2006 um 19:17 schrieb Michael Bommarito:
>
> > This didn't get much attention on bugzilla and I figured it was
> > important enough to forward along to the whole list since it's been
> > lingering around in ieee80211-softmac since 19-git5 at least.
> > http://bugzilla.kernel.org/show_bug.cgi?id=7657
> >
> > Somebody was passing the whole mac device structure to
> > ieee80211softmac_assoc_work instead of just the assocation work, which
> > lead to much death and locking.
> >
> > Attached is a patch that fixes this (the actual change is two lines
> > but context provided in patch for review).  The dmesg containing call
> > trace is attached to the bugzilla entry above.
> >
> > -Mike
> > -
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Uli Kunitz
>
>
>
>
