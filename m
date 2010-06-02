From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 19:52:37 +0200
Message-ID: <1275501157.3915.22.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
	 <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	 <m14ohlxu51.fsf@fess.ebiederm.org>
	 <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	 <m1ocftwdp7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:55565 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377Ab0FBRwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 13:52:39 -0400
In-Reply-To: <m1ocftwdp7.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 10:23 -0700, Eric W. Biederman wrote:

> So far that hypothesis that the target of the symlink is being removed before
> the actual actual link looks like it could cause this.

Yeah though I'm not sure how that would happen? Wouldn't the symlink
cause the target kobject to still be referenced, and thus stay around
until the symlink goes away?

> Are there any other left overs in sysfs, besides just /sys/class/net/wlan0?

No, not based on find /sys and diffing before/after anyway.

johannes

