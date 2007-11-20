From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Wed, 21 Nov 2007 00:45:05 +0100
Message-ID: <20071120234505.GF23667@elte.hu>
References: <4743026B.2020907@openvz.org> <m11wakshyz.fsf@ebiederm.dsl.xmission.com> <20071120215914.GE24156@elte.hu> <m1ve7wr28z.fsf@ebiederm.dsl.xmission.com> <20071120223559.GA6655@elte.hu> <20071120225457.B6E2D26F8BE@magilla.localdomain> <20071120230106.GD24380@elte.hu> <3d8471ca0711201506t6b2b88a0h9484f8a40a1f2e40@mail.gmail.com> <20071120232600.F1D2F26F8BE@magilla.localdomain> <47436E7F.2060901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland McGrath <roland@redhat.com>,
	Guillaume Chazarain <guichaz@yahoo.fr>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:56395 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754979AbXKTXpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 18:45:19 -0500
Content-Disposition: inline
In-Reply-To: <47436E7F.2060901@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ulrich Drepper <drepper@redhat.com> wrote:

> > Oh, it seems it has indeed been that way for a very long time, so I 
> > was mistaken.  It still seems a little odd to me.  Ulrich can say 
> > definitively whether the kind of concern I mentioned really matters 
> > one way or the other for glibc.
> 
> glibc cannot survive (at least NPTL) if somebody uses funny CLONE_* 
> flags to separate various pieces of information, e.g., file 
> descriptors.
>  So, all the information in each thread's /proc/self should be 
>  identical.
> 
> When the information is not the same, the current semantics seems to 
> be more useful.  So I guess, no change is the way to go here.

can you see any danger to providing a /proc/self_task/ link? (or can you 
think of a better name/API/approach)

	Ingo
