From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Bugme-new] [Bug 16257] New: sysfs changes break hwsim and bnep drivers
Date: Mon, 21 Jun 2010 15:55:35 -0700
Message-ID: <m1eig0dmhk.fsf@fess.ebiederm.org>
References: <bug-16257-10286@https.bugzilla.kernel.org/>
	<20100621150826.762ac9f2.akpm@linux-foundation.org>
	<m1mxuodo0n.fsf@fess.ebiederm.org> <20100621222938.GA20583@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46670 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755794Ab0FUWz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 18:55:59 -0400
In-Reply-To: <20100621222938.GA20583@suse.de> (Greg KH's message of "Mon\, 21 Jun 2010 15\:29\:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <gregkh@suse.de> writes:

> I _really_ do not like this patch.
>
> The correct thing is to fix the modules that are affected, and that's
> only the wireless testing module, right?  Or is there something else?
>
> And if that code is properly converted to a bus, what needs to change in
> the driver core?

The usb bnep driver.

Eric
