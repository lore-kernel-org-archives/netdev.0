From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned
 to  classes
Date: Tue, 08 Jun 2010 16:06:10 +0200
Message-ID: <1276005970.3706.132.camel@jlt3.sipsolutions.net>
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
	 <1275990325.3706.116.camel@jlt3.sipsolutions.net>
	 <1275998127.1899.38.camel@yio.site>
	 <1275998603.3706.118.camel@jlt3.sipsolutions.net>
	 <AANLkTinev96yxFCFSdDdT89jjgYR4ChUCMU2-aSj8kkh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:36081 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530Ab0FHOGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 10:06:16 -0400
In-Reply-To: <AANLkTinev96yxFCFSdDdT89jjgYR4ChUCMU2-aSj8kkh@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-08 at 15:54 +0200, Kay Sievers wrote:
> On Tue, Jun 8, 2010 at 14:03, Johannes Berg <johannes@sipsolutions.net> wrote:
> > On Tue, 2010-06-08 at 13:55 +0200, Kay Sievers wrote:
> >
> >> Ok, this needs testing.
> >>
> >> Please let me know, if that works for you so far.
> >
> > Will do. Just a question: none of this seems to pin the module? So can I
> > be sure if I rmmod the module that the release function will still be
> > around etc.?
> 
> Oh, sorry, that's something very specific to network devices, that the
> module can be unloaded while the devices it has created are still in
> use. I am not sure right now what's needed to make this work in a
> single module.

Well they will be unregistered and everything, but once all the netdevs
are gone etc. the devices you create in the patch might stick around
because somebody has them open in sysfs, and I see nothing that would
pin the module in that case?

johannes

