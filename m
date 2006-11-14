From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7502] New: sunhme not working with 2.6.18 on
 x86
Date: Mon, 13 Nov 2006 18:10:52 -0800
Message-ID: <20061113181052.b84b73ad.akpm@osdl.org>
References: <200611130048.kAD0mduX009385@fire-2.osdl.org>
	<1170.20061114025022.mpokrywka@hoga.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17344 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S933316AbWKNCLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 21:11:09 -0500
To: "Michal Pokrywka" <mpokrywka@hoga.pl>
In-Reply-To: <1170.20061114025022.mpokrywka@hoga.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Nov 2006 02:50:22 +0100
"Michal Pokrywka" <mpokrywka@hoga.pl> wrote:

> > I'd have expected that this would have been caused by i386 platform
> > borkage.  But in the debian bug report, Michal has fingered davem's
> > http://www.kernel.org/git/?p=linux/kernel/git/stable/linux-2.6.18.y.
> > git;a=commit;h=050bbb196392b9c178f82b1205a23dd2f915ee93
> > as the cause.
> > 
> > Michal, what makes you believe that this particualr patch is to
> > blame?
> 
> Sorry, I'm not git expert, I only browsed sunhme.c changes through
> http interface and I downloaded a11 driver revisions between what
> I considered 2.6.17 driver (by date) and latest revision.
> I compiled all revisions by hand and insmoded all these modules
> until driver worked. Probably I didn't mentioned it in bug report,
> but after loading working driver and kernel assigning correct
> interrupts as seen in dmesg, all driver revisions loaded afterwards
> worked, even those bad.
> >From my pov driver is broken, because older version works with
> 2.6.18.
> 

OK, thanks.  That method works ;)

The usual technique is git-bisect.  That's briefly described in
Documentation/BUG-HUNTING, but that just send you to the git-bisect
manpage.  Perhaps we need a super-simple kernel-specific document.

But anyway.  That's for next time.
