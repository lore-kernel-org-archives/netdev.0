From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned
 to classes
Date: Fri, 04 Jun 2010 08:54:12 +0200
Message-ID: <1275634452.5189.1.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
	 <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	 <m14ohlxu51.fsf@fess.ebiederm.org>
	 <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	 <m1ocftwdp7.fsf@fess.ebiederm.org>
	 <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	 <m1y6exux6x.fsf@fess.ebiederm.org>
	 <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	 <m16321t4ke.fsf@fess.ebiederm.org>  <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>,
	Kay Sievers <kay.sievers@vrfy.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:49608 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073Ab0FDGyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 02:54:36 -0400
In-Reply-To: <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 17:53 -0700, Eric W. Biederman wrote:

> Johannes this should fix your issue with mac80211_hwsim, where
> the device symlink were not destroyed when the driver was removed.

It does, thank you.

FWIW, I'm happy changing hwsim too, but I don't think I quite understand
what you're proposing in your other email so I'll leave it up to you
since you now know what is causing the problem :)

johannes

