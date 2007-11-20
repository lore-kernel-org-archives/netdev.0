From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Wed, 21 Nov 2007 00:01:06 +0100
Message-ID: <20071120230106.GD24380@elte.hu>
References: <20071119191000.GA1560@elf.ucw.cz> <200711192304.25087.rjw@sisk.pl> <4743026B.2020907@openvz.org> <m11wakshyz.fsf@ebiederm.dsl.xmission.com> <20071120215914.GE24156@elte.hu> <m1ve7wr28z.fsf@ebiederm.dsl.xmission.com> <20071120223559.GA6655@elte.hu> <20071120225457.B6E2D26F8BE@magilla.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Ulrich Drepper <drepper@redhat.com>
To: Roland McGrath <roland@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:34689 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752144AbXKTXBg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 18:01:36 -0500
Content-Disposition: inline
In-Reply-To: <20071120225457.B6E2D26F8BE@magilla.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Roland McGrath <roland@redhat.com> wrote:

> When did /proc/self get changed to follow tgid instead of pid?  glibc 
> uses /proc/self to refer to various things that are usually shared 
> anyway (fd, maps, cwd, exe), but I think the expectation has always 
> been that this refers to the same calling thread, not the group 
> leader.  e.g., if one thread has changed uids so it no longer has 
> access to the group leader's /proc/PID/fd, suddenly it using 
> /proc/self/fd starts failing.

i guess it was a v2.6.24 change, hence a regression that needs to be 
fixed?

	Ingo
