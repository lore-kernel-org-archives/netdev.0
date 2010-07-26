From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Driver-core: Always create class directories for
 classses that support namespaces.
Date: Mon, 26 Jul 2010 11:07:40 -0700
Message-ID: <20100726180739.GA4883@kroah.com>
References: <m139vd5sms.fsf_-_@fess.ebiederm.org>
 <m1zkxj27xp.fsf_-_@fess.ebiederm.org>
 <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
 <m1vd87toy9.fsf@fess.ebiederm.org>
 <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
 <1279822828.12439.24.camel@jlt3.sipsolutions.net>
 <20100722182827.GA12821@suse.de>
 <1279823801.12439.31.camel@jlt3.sipsolutions.net>
 <20100722185449.GB528@suse.de>
 <m1tynonmk8.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>,
	"<linux-kernel@vger.kernel.org> Marcel Holtmann"
	<marcel@holtmann.org>, linux-bluetooth@vger.kernel.org,
	Greg KH <gregkh@suse.de>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:42276 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751271Ab0GZSKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jul 2010 14:10:21 -0400
Content-Disposition: inline
In-Reply-To: <m1tynonmk8.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 24, 2010 at 10:43:35PM -0700, Eric W. Biederman wrote:
> p.s. Linus my apologies for sending this directly but I have gotten an
> incredible amount of flak trying to fix this problem, and I would like
> not to leave an accidental regression whose cause is well known in
> 2.6.35 if I can help it.

"flak"?

{sigh}

No, it's just been an issue of fixing the issue in the correct manner.
You sent this patch a mere 2 days prior, and I've been away since then
and haven't even _had_ the chance to apply it to my tree and run it
through any testing.

Heck, it hasn't even been in the linux-next tree, and seen if it blows
up Andrew's notorious machine.

Next time, give me a chance to at least build your patch before getting
upset and routing around me.  The other 2 patches you have sent me have
had testing in linux-next and will go to Linus later today, and I have
half-a-mind to revert this one, but I just know you will be willing to
fix up any problems found in it now :)

What a nice way to return from a 3day vacation...

greg k-h
