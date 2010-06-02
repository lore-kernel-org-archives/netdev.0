From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 21:12:56 +0200
Message-ID: <1275505976.3915.32.camel@jlt3.sipsolutions.net>
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
	 <1275504953.3915.31.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:39977 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758558Ab0FBTM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 15:12:58 -0400
In-Reply-To: <1275504953.3915.31.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 20:55 +0200, Johannes Berg wrote:
> On Wed, 2010-06-02 at 11:05 -0700, Eric W. Biederman wrote:
> 
> > If you want to dig into this look at sysfs_delete_link.  instrument
> > it so that you can see if it is called for wlan{0,1,2} and see what
> > ns it is called for.
> > 
> > My current hypothesis is something is causing us to try and delete
> > the symlink from the wrong namespace, so we just skip that part of it.
> 
> [   78.253128] create link wlan0 ns=ffff88001ce1e600
> ...
> [   93.462268] delete link wlan0 ns=ffff88001ce1e600

No that was the sd, but sd->s_ns is NULL in both cases.

johannes

