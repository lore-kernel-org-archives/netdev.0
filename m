From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC][PATCH] mac80211_hwsim: No parent is better than an
 illegimate one.
Date: Mon, 12 Jul 2010 16:29:15 +0200
Message-ID: <1278944955.5870.29.camel@jlt3.sipsolutions.net>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	 <20100621150826.762ac9f2.akpm@linux-foundation.org>
	 <m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
	 <m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	 <m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	 <m1630q7x5v.fsf_-_@fess.ebiederm.org> <m1zky26iaw.fsf_-_@fess.ebiederm.org>
	 <1278917200.3667.1.camel@jlt3.sipsolutions.net>
	 <m11vb8u6cy.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>, Greg KH <greg@kroah.com>,
	"Greg KH <gregkh@suse.de> netdev" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:36186 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755357Ab0GLOaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 10:30:08 -0400
In-Reply-To: <m11vb8u6cy.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-07-12 at 07:23 -0700, Eric W. Biederman wrote:

> > It'll probably work, but anything in userspace relying on it will fail,
> > and you'll have some unused virtual devices in sysfs?
> 
> Well anything in userspace that isn't mac80211_hwsim specific will
> likely already fail because the format of the link is different for
> mac80211_hwsim then for every other wireless device.

Well, I seem to have a vague memory of network-manager for example
requiring the link but not really caring much what it is, but I might
remember something else that wasn't hwsim related.

johannes

