From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned
 to  classes
Date: Tue, 08 Jun 2010 11:45:25 +0200
Message-ID: <1275990325.3706.116.camel@jlt3.sipsolutions.net>
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
	 <m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	 <1275634452.5189.1.camel@jlt3.sipsolutions.net>
	 <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
	 <1275640113.9953.8.camel@jlt3.sipsolutions.net>
	 <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
	 <1275829701.3615.54.camel@jlt3.sipsolutions.net>
	 <AANLkTinUAR2gkY7ipgXKy-pMHcmLuouEeyXxnP97U_7N@mail.gmail.com>
	 <1275903773.29978.1.camel@jlt3.sipsolutions.net>
	 <AANLkTin_qjU0-xXfMDYeYWRd0BmvT4OIdK4S_GQ3ZYUi@mail.gmail.com>
	 <1275905686.29978.3.camel@jlt3.sipsolutions.net>
	 <AANLkTikMDvpEzrtFVue8gStudKONxuQmVx9B2w1JM1vO@mail.gmail.com>
	 <1275910905.29978.7.camel@jlt3.sipsolutions.net>
	 <1275913563.1823.1.camel@yio.site>
	 <1275914205.29978.10.camel@jlt3.sipsolutions.net>
	 <AANLkTilqB2sAyfBTLhYT_a2_TySGay4FFG6SGJUZ1o_4@mail.gmail.com>
	 <1275989260.3706.115.camel@jlt3.sipsolutions.net>
	 <AANLkTinMauFsJTKS3eT-pT44KQ8PSf3HJLS8CZIeHmxP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:51620 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629Ab0FHJpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 05:45:32 -0400
In-Reply-To: <AANLkTinMauFsJTKS3eT-pT44KQ8PSf3HJLS8CZIeHmxP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-08 at 11:30 +0200, Kay Sievers wrote:
> On Tue, Jun 8, 2010 at 11:27, Johannes Berg <johannes@sipsolutions.net> wrote:
> > On Mon, 2010-06-07 at 14:54 +0200, Kay Sievers wrote:
> >
> >> > I see you remove the driver. Does this mean that in sysfs these devices
> >> > wouldn't have a driver symlink? ISTR that we needed that for userspace,
> >> > but I'm not entirely sure, and I don't have all the relevant userspace
> >> > in my test setup.
> >>
> >> Yeah, if you need the driver, you need to use bus device, as you do
> >> now. The driver needs to be registered with the core, and the probe
> >> function needs to tell to bind to the devices while registered. You
> >> can not manually assign this.
> >
> > So I spoke to Jouni and he says that he doesn't remember needing the
> > driver, so I guess we don't care. Can I get you to submit that patch
> > properly? Send it to linux-wireless@vger.kernel.org please.
> 
> Sure, you mean the patch that changes the hwsim code, or the one I
> talked about to properly create a virtual bus parent?

The hwsim one you pasted earlier.

johannes

